# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# railscast 88 revised
# http://railscasts.com/episodes/88-dynamic-select-menus-revised?view=comments
# 
jQuery ->
  o = []
  groepen = $('#zwemmer_groep_id').html()
  groep_niveau = ""
  if $('#zwemmer_groep_id :selected').length
    groep_niveau = $('#zwemmer_groep_id :selected').text().match(/\w+\s+\w+\s+(.*)\s\w*/)[1]
  $('optgroup').each ->
    o.push(this.label)
  kla = $('#zwemmer_kla_id :selected').text()
  for op in o 
    if op.indexOf(kla + "-") != -1
      groep = op
  options = $(groepen).filter("optgroup[label='#{groep}']").html()
  $('#zwemmer_groep_id').html(options)
  pas_groep_aan_klas = ->
    kla = $('#zwemmer_kla_id :selected').text()
    for op in o 
      if op.indexOf(kla + "-") != -1
        groep = op
    options = $(groepen).filter("optgroup[label='#{groep}']").html()
    $('#zwemmer_groep_id').html(options)
  $('#zwemmer_kla_id').change ->
    pas_groep_aan_klas()
    gevonden = false
    $('#zwemmer_groep_id option').each ->
      option_niveau = $(this).text().match(/\w+\s+\w+\s+(.*)\s\w*/)[1]
      if option_niveau == groep_niveau
        $(this).prop('selected', true)
        gevonden = true
        return false
    if gevonden == false
      $("#groep_select_extra").css("background-color", "red")
    else
      $("#groep_select_extra").css("background-color", "white")
  $('li.menu').css('cursor', 'pointer')
  $('.een').hide()
  huidig = 'gegevens'
  $huidigli = $('li.active')
  $(".gegevens").show()
  $('li.menu').click ->
    if $(this).attr('id') != $huidigli.attr('id')
      #alert($(this).attr('class'))
      $(this).addClass("active")
      $huidigli.removeClass("active")
      $(".#{huidig}").hide()
      $(".#{$(this).attr('id')}").show()
      huidig = $(this).attr('id')
      $huidigli = $(this)
  $('.massselect').click ->
    $('input:checkbox').each ->
      $(this).prop('checked', true)
  $('.massunselect').click ->
    $('input:checkbox').each ->
      $(this).prop('checked', false)
  $('.select6es').click ->
    $('.6').each ->
      $(this).prop('checked', true)
###
  counter = 0
  for i in [1..max] by 1
    $("##{i}").hide()
  @g = g = () ->
    $("##{counter}").hide()
    counter = counter - 1
    if counter < 0
      counter = max
    $("##{counter}").show()
    #$("##{counter}").effect('slide', { direction: "left" })
  @h = h = () ->
    $("##{counter}").hide()
    counter = counter + 1
    if counter > max
      counter = 0
    $("##{counter}").show()
    #$("##{counter}").effect('slide', { direction: "right" })
###
