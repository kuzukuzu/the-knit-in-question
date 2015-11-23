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
