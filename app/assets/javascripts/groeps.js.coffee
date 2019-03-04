# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# http://stackoverflow.com/questions/426258/how-do-i-check-a-checkbox-with-jquery-or-javascript
jQuery ->
	$('.radiopanel [type="radio"]').dblclick ->
		value = $(this).val()
		parent = $(this).parents('.hero-unit')
		parent.find('[type="radio"]').each ->
			if $(this).val() == value
				$(this).prop("checked", true)
				check_this($(this))
	$('.radiopanel [type="radio"]').change ->
		$(this).closest('label').siblings().css('color', 'black')
		$(this).closest('label').siblings().css('font-weight', 'normal')
		$(this).closest('label').css('color', 'green')
		$(this).closest('label').css('font-weight', 'bold')
	check_this = (x) ->
		x.closest('label').siblings().css('color', 'black')
		x.closest('label').siblings().css('font-weight', 'normal')
		x.closest('label').css('color', 'green')
		x.closest('label').css('font-weight', 'bold')
	$('.radiopanel [type="radio"]').each ->
		if $(this).is(':checked')
			$(this).closest('label').css('color', 'green')
			$(this).closest('label').css('font-weight', 'bold')
	$('.check').each ->
		if $(this).is(':checked') and this.id.substr(0,6) == 'update'
	  		$naamobject = $("##{this.id}")
	  		if $naamobject.html().search( 'icon-ok') == -1
		  		$naamobject.html($naamobject.html() + ' <i class="icon-ok icon"></i>')	
	$('.gover').each ->
		if $(this).is(':checked') and this.id.substr(-8,8) == 'overvlag'
			$naamobject = $("##{'update' + this.id.replace(/[^\d\.]/g, '')}")
			if $naamobject.html().search( 'icon-plus') == -1
				$naamobject.html($naamobject.html() + ' <i class="icon-plus icon"></i>')
	$('.accordion-toggle').click ->
		id = $(this).attr('href')
		if $("#{id}").attr('class') == 'accordion-body collapse'
			#alert($("#{id}").scrollTop())
			sub = parseInt(id.substring(9, id.length))+1
			$(window).scrollTop(sub*sub+sub)
		$('.check').each ->
			if $(this).is(':checked')
			  	$naamobject = $("##{this.id}")
	  			if $naamobject.html().search( 'icon-ok') == -1
		  			$naamobject.html($naamobject.html() + ' <i class="icon-ok icon"></i>')
		  	else
		  		$naamobject = $("##{this.id}")
	  			if $naamobject.html().search( 'icon-ok') != -1
	  				$naamobject.html($naamobject.html().replace(' <i class="icon-ok icon"></i>', ''))
		$('.gover').each ->
			if $(this).is(':checked')
				# haal alle niet-nummers uit id en plak het achter update
				$naamobject = $("##{'update' + this.id.replace(/[^\d\.]/g, '')}")
				if $naamobject.html().search('icon-plus') == -1
					$naamobject.html($naamobject.html() + ' <i class="icon-plus icon"></i>')
			else
				$naamobject = $("##{'update' + this.id.replace(/[^\d\.]/g, '')}")
				if $naamobject.html().search('icon-plus') != -1
					$naamobject.html($naamobject.html().replace(' <i class="icon-plus icon"></i>', ''))
	$('.verberg').click ->
		$("#fouten_#{this.id}").toggle()
		#if $(this).attr("class").search('icon-eye-close') != -1
		#	$(this).removeClass('icon-eye-close')
		#	$(this).addClass('icon-eye-open')
			#$(this).html($(this).html().replace('icon-eye-close', 'icon-eye-open'))
		#else
			#$(this).html($(this).html().replace('icon-eye-open', 'icon-eye-close'))
		#	$(this).removeClass('icon-eye-open')
		#	$(this).addClass('icon-eye-close')
	$('.fouten_div').toggle()



