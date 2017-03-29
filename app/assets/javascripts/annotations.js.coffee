showUserInfo = (v) ->
    updateViewer = (field, annotation) ->
        field = $(field)
        if annotation.user
            field.addClass('.annotator-author').html( ->
                date = new Date(annotation.updated_at)
                options = {
                    weekday: "long", 
                    year: "numeric", 
                    month: "short",
                    day: "numeric", 
                    hour: "2-digit", 
                    minute: "2-digit"
                }
                return "<span class='hi'><strong>Added by:</strong> #{annotation.user} <br /><strong>On:</strong> #{date.toLocaleDateString("en-US", options)}</span>"
            )
        else
            field.remove()

    v.addField
        load: updateViewer

addClassification = (v) ->
  updateViewer = (field, annotation) ->
    field = $(field)
    if annotation.classification
      field.addClass('.annotation-class').html( ->
        return "<span class='an_class'><strong>Comment Type:</strong> #{annotation.classification}</span>"
      )
    else
      field.remove()

  v.addField
    load: updateViewer

addClassificationToEditor  = (e) ->
  field = null
  input = null

  updateField = (field, annotation) ->
    value = ''
    field = $(field)
    value = annotation.classification if annotation.classification

    field.addClass('.annotation-class-edit').html( ->
      "<label>Comment Type:</label><select name='classification' id='classification'><option>Select One...</option><option value='Legal'>Legal</option><option value='Fact'>Fact</option><option value='Structure'>Structure</option><option value='Voice'>Voice</option><option value='Format'>Format</option></select>"
    )
    field.find('#classification').val(value)

  setAnnotationClassification = (field, annotation) ->
    console.log $(field).find(":input").val()
    annotation.classification = $(field).find(":input").val()

  field = e.addField({
    type: 'select'
    label: "Pick a classification:"
    load: updateField
    submit: setAnnotationClassification
  })

  input = $(field).find(":input")

$ ->
    resource_id = $('#fl_container').attr('data-object-id')

    app = new annotator.App()
    window.app = app
    app.include(annotator.ui.main, {
        element: document.querySelector('#main')
        viewerExtensions: [showUserInfo, addClassification]
        editorExtensions: [addClassificationToEditor]
    })    
    app.include(annotator.identity.simple)
    app.include(annotator.storage.http, {
        prefix: "/api/v1"
    })
    app.start()
       .then( () ->
            $.getJSON "/api/v1/annotations/user", (data) ->
                app.ident.identity = data.user
            app.annotations.load({ id: resource_id }) )


