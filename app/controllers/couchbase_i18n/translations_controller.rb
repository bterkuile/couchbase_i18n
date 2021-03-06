module CouchbaseI18n
  class TranslationsController < CouchbaseI18n::ApplicationController
    def index
      @available_higher_offsets = []
      @available_deeper_offsets = []
      per_page = params[:per_page].presence.try(:to_i) || 30
      if params[:partfinder].present?
        if untranslated?
          @translations = CouchbaseI18n::Translation.find_all_untranslated_by_translation_key_part(params[:offset], page: params[:page], per_page: per_page)
        else
          @translations = CouchbaseI18n::Translation.find_all_by_translation_key_part(params[:offset], page: params[:page], per_page: per_page)
        end
      elsif params[:valuefinder].present?
        if untranslated?
          @translations = CouchbaseI18n::Translation.find_all_untranslated_by_translation_value(params[:offset], page: params[:page], per_page: per_page)
        else
          @translations = CouchbaseI18n::Translation.find_all_by_translation_value(params[:offset], page: params[:page], per_page: per_page)
        end
      else
        if params[:offset].present?
          if untranslated?
            @translations = CouchbaseI18n::Translation.untranslated_with_offset(params[:offset], :page => params[:page], :per_page => per_page)
          else
            @translations = CouchbaseI18n::Translation.with_offset(params[:offset], :page => params[:page], :per_page => per_page)
          end
        else
          if untranslated?
            @translations = CouchbaseI18n::Translation.untranslated(:page => params[:page], :per_page => per_page)
          else
            @translations = CouchbaseI18n::Translation.all(:page => params[:page], :per_page => per_page)
          end
        end
        @available_higher_offsets = CouchbaseI18n::Translation.higher_translation_keys_for_offset(params[:offset])
        @available_deeper_offsets = CouchbaseI18n::Translation.deeper_translation_keys_for_offset(params[:offset])
      end
    end

    def show
      redirect_to action: :edit
    end

    def new
      @translation = CouchbaseI18n::Translation.new :key => params[:offset]
    end

    def create
      @translation = CouchbaseI18n::Translation.new params[:translation]
      if @translation.translation_value.present? && params[:is_json].present?
        @translation.translation_value = JSON.parse(@translation.value)
      end
      if @translation.save
        redirect_to({:action => :index, :offset => @translation.translation_key.to_s.sub(/\.[\w\s-]+$/, '')}, :notice => I18n.t('couchbase_i18n.action.create.successful', :model => CouchbaseI18n::Translation.model_name.human))
      else
        render :action => :new
      end
    end

    # GET /couchbase_i18n/translations/:id/edit
    def edit
      @translation = CouchbaseI18n::Translation.find(params[:id])
    end

    # PUT /couchbase_i18n/translations/:id
    def update
      @translation = CouchbaseI18n::Translation.find(params[:id])
      @translation.translated = true
      if params[:translation]["translation_value"].present? && params[:is_json].present?
        params[:translation]["translation_value"] = JSON.parse(params[:translation]["value"])
      end
      if @translation.update_attributes(params[:translation])
        redirect_to({:action => :index, :offset => @translation.translation_key.to_s.sub(/\.[\w\s-]+$/, '')}, :notice => I18n.t('couchbase_i18n.action.update.successful', :model => CouchbaseI18n::Translation.model_name.human))
      else
        render :action => :edit
      end
    end

    def destroy
      @translation = CouchbaseI18n::Translation.find(params[:id])
      if @translation.destroy
        flash[:notice] = I18n.t('couchbase_i18n.action.destroy.successful', :model => CouchbaseI18n::Translation.model_name.human)
      end
      redirect_to({:action => :index, :offset => @translation.translation_key.to_s.sub(/\.\w+$/, '')})
    end

    # POST /couchbase_i18n/translations/export
    # Export to yml, csv or json
    def export
      if params[:offset].present?
        if params[:untranslated].present?
          @translations = CouchbaseI18n::Translation.unstranslated_with_offset(params[:offset])
        else
          @translations = CouchbaseI18n::Translation.with_offset(params[:offset])
        end
      else
        if params[:untranslated].present?
          @translations = CouchbaseI18n::Translation.untranslated
        else
          @translations = CouchbaseI18n::Translation.all
        end
      end
      base_filename = "export#{Time.now.strftime('%Y%m%d%H%M')}"
      if params[:exportformat] == 'csv'
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = %{attachment; filename="#{base_filename}.csv"}
        render :text => @translations.map{|s| [s.translation_key, s.translation_value.to_json].join(',')}.join("\n")
      elsif params[:exportformat] == 'json'
        response.headers['Content-Type'] = 'application/json'
        response.headers['Content-Disposition'] = %{attachment; filename="#{base_filename}.json"}
        # render :text => CouchbaseI18n.indent_translation_keys(@translations).to_json # for indented json
        render :json => @translations.map{|s| {s.translation_key => s.translation_value}}.to_json
      else #yaml
        response.headers['Content-Type'] = 'application/x-yaml'
        response.headers['Content-Disposition'] = %{attachment; filename="#{base_filename}.yml"}
        render :text => CouchbaseI18n.indent_translation_keys(@translations).to_yaml
      end
    end

    # POST /couchbase_i18n/translations/import
    # Import yml files
    def import
      redirect_to({:action => :index, :offset => params[:offset]}, :alert => I18n.t('couchbase_i18n.translation.no_import_file_given')) and return unless params[:importfile].present?
      filename = params[:importfile].original_filename
      extension = filename.sub(/.*\./, '')
      if extension == 'yml'
        hash = YAML.load_file(params[:importfile].tempfile.path) rescue nil
        redirect_to({:action => :index, :offset => params[:offset]}, :alert => I18n.t('couchbase_i18n.translation.cannot_parse_yaml')) and return unless hash
        CouchbaseI18n.traverse_flatten_keys(hash).each do |key, value|
          existing = CouchbaseI18n::Translation.find_by_translation_key(key)
          if existing
            if existing.translation_value != value
              existing.translation_value = value
              existing.translated = true
              existing.save
            end
          else
            CouchbaseI18n::Translation.create :translation_key => key, :translation_value => value
          end
        end 
      else
        redirect_to({:action => :index, :offset => params[:offset]}, :alert => I18n.t('couchbase_i18n.translation.no_proper_import_extension', :extension => extension)) and return 
      end
      redirect_to({:action => :index, :offset => params[:offset]}, :notice => I18n.t('couchbase_i18n.translation.file_imported', :filename => filename))
    end

    # Very dangarous action, please handle this with care, large removals are supported!
    # DELETE /couchbase_i18n/translations/destroy_offset?...
    def destroy_offset
      if params[:offset].present?
        if params[:untranslated].present?
          @translations = CouchbaseI18n::Translation.untranslated_with_offset(params[:offset])
        else
          @translations = CouchbaseI18n::Translation.with_offset(params[:offset])
        end
      else
        if params[:untranslated].present?
          @translations = CouchbaseI18n::Translation.untranslated
        else
          @translations = CouchbaseI18n::Translation.all
        end
      end
      @translations.map(&:destroy)
      redirect_to({:action => :index}, :notice => I18n.t('couchbase_i18n.translation.offset_deleted', :count => @translations.size, :offset => params[:offset]))
    end

    private

    def untranslated?
      params[:untranslated].presence
    end
    helper_method :untranslated?
  end
end
