function(doc, meta){
  if(doc.type == 'couchbase_i18n/translation') {
    emit(doc.translation_key.split('.').slice(0, -1), 1)
  }
}
