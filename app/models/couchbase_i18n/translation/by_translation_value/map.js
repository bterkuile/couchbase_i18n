function(doc, meta){
  if(doc.type == 'couchbase_i18n/translation') {
    emit(doc.translation_value, 1);
  }
}
