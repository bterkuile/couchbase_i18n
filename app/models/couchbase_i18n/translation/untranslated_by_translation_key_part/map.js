function(doc, meta){
  if(doc.type == 'couchbase_i18n/translation' && !doc.translated) {
    var parts = doc.translation_key.split('.');
    for(var i = 0; i < parts.length; i++){
      emit(parts[i], 1);
    }
  }
}
