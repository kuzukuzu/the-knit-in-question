$ ->
  $inputTop = $('input[name=top]')
  $inputLeft = $('input[name=left]')
  $inputDir = $('input[name=dir]')

  # 帽子の移動
  $('#knit').draggable
    containment: '#workspace'
    stop: (event, ui)->
      $inputTop.val(ui.position.top)
      $inputLeft.val(ui.position.left)

  # 帽子の反転
  $('#knit').dblclick ->
    $(this).toggleClass("reversed")
    currentDir = $inputDir.val()
    $inputDir.val((currentDir - 0) * -1)

  # ajax post
  $('form').submit (event)->
    event.preventDefault()

    $form = $(this)
    $dimmer = $('ui dimmer')

    $.ajax
      url: $form.attr('action')
      type: $form.attr('method')
      data: $form.serialize()
      beforeSend: (xhr, settings)->
        $dimmer.addClass 'active'
      complete: (xhr, textStatus)->
        $dimmer.removeClass 'active'
      success: (result, textStatus, xhr)->
        $('#message-success').transition 'scale'
        setTimeout("$('#message-success').transition('fade');", 3000)
      error: (result, textStatus, xhr)->
        $('#message-error').transition 'scale'
        setTimeout("$('#message-error').transition('fade');", 3000)
