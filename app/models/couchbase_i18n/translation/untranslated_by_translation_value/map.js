function(doc, meta){
  if(doc.type == 'couchbase_i18n/translation' && !doc.translated) {
    emit(doc.translation_value, 1);
  }
}
