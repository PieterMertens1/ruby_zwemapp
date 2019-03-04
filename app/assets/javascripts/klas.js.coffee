# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	$('.radio_buttons.kla_week').hide()
	if $('#kla_tweeweek').is(':checked')
		$("label.radio:first").hide()
		$('.radio_buttons.kla_week').show()
	$('#kla_tweeweek').change ->
		if $(this).is(':checked')
			$('.radio_buttons').show()
			$radios = $("input:radio[name='kla[week]']")
			#$('input:radio:first').remove();
			$("label.radio:first").hide()
			$radios.filter('[value=0]').prop('checked', false)
			$radios.filter('[value=1]').prop('checked', true)
		else
			$radios = $("input:radio[name='kla[week]']")
			$("label.radio:first").show()
			$radios.filter('[value=1]').prop('checked', false)
			$radios.filter('[value=0]').prop('checked', true)
			$('.radio_buttons').hide()