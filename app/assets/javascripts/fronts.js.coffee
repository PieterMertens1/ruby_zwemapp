# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# waarom @g = g = () ? https://groups.google.com/forum/#!msg/coffeescript/PzNU0NtVY2c/zu_3kaG4nV4J
###
jQuery ->

	counter = 1
	for i in [2..6] by 1
		$("##{i}").hide()

	@g = g = () ->
		$("##{counter}").hide()
		counter = counter - 1
		if counter < 1
			counter = 6
		$("##{counter}").show()
	@h = h = () ->
		$("##{counter}").hide()
		counter = counter + 1
		if counter > 6
			counter = 1
		$("##{counter}").show()
###
# http://stackoverflow.com/questions/1726747/jquery-how-do-you-loop-through-each-newline-of-text-typed-inside-a-textarea
jQuery ->
	$('#spinner').hide()
	$('div#foto_pill').hide()
	$('div#comp_pill').hide()
	$("#pictures2").attr("disabled", "disabled")
	injaar1 = "1"
	injaar2 = "1"
	school_active_counter = 1
	to_percentage = (a) ->
		total = 0
		total = a.reduce (t, s) -> t + s
		return a.map (i) -> 
			if i==0
				0
			else
				parseInt(Math.round((i/total)*100).toFixed(2))
	adjust_stat_file_link = (n) ->
		school_id1 = $('#schools1').find(":selected").val()
		school_id2 = $('#schools2').find(":selected").val()
		if (n == 1) || (n == "1")
			pdf_url = '/fronts/stat_file.pdf?school='+school_id1+'&jaar='+ injaar1 
			xls_url = '/fronts/stat_file.xls?school='+school_id1+'&jaar='+ injaar1 
			$('#stat_pdf1').attr('href', pdf_url)
			$('#stat_exc1').attr('href', xls_url)
		else
			pdf_url = '/fronts/stat_file.pdf?school='+school_id2+'&jaar='+ injaar2 
			xls_url = '/fronts/stat_file.xls?school='+school_id2+'&jaar='+ injaar2 
			$('#stat_pdf2').attr('href', pdf_url)
			$('#stat_exc2').attr('href', xls_url)
	redraw_autotafel = ->
		$('#spinner').show()
		$('#autotafel').empty()
		text = jQuery("textarea#userinvoer").val()
		niveau_id = jQuery("select#niveau").val()
		$('#autotafel').hide()
		$.get('autoinfo', {zwemmers: text, niveau: niveau_id}, (response) ->
			antwoord = jQuery.parseJSON(response.zwemmers)
			#alert(response.zwemmers)
			if antwoord.length > 0
				$("<tr><td style=\"padding: 4px;\">Nieuw?</td><td style=\"padding: 4px\">Naam</td><td style=\"padding: 4px\">Gelijkaardig</td></tr>").appendTo('#autotafel')
			for z in antwoord
				#alert(z)
				left_button = ""
				right_buttons = ""
				if z[3] != ""
					left_button = "<button name=\"area_wijzig\" style=\"float:right\"type=\"button\" class=\"btn btn-default area_wijzig\">Wijzig</button>"
					right_buttons = "<button name=\"import_wijzig\" id=\"#{z[4]}\"style=\"float:right\"type=\"button\" class=\"btn btn-default import_wijzig\">Wijzig</button>"
				$("<tr style=\"background-color: #{z[1]}\"><td style=\"padding: 4px;\"> #{z[2]}</td><td style=\"padding: 4px; font-size: 9px;\">#{z[0]}#{left_button}</td><td style=\"padding: 4px; font-size: 9px;background-color: #{z[5]}\">#{z[3]}#{right_buttons}</td></tr>").appendTo('#autotafel')
			$('#spinner').hide())
		$('#autotafel').fadeIn('slow')
	get_and_draw =  ->
		$('#spinner').show()
		$.get('getstat', {jaar1: injaar1,jaar2: injaar2, school1: $('#schools1').find(":selected").val(), school2: $('#schools2').find(":selected").val(), picture1: $('#pictures1').find(":selected").val(), picture2: $('#pictures2').find(":selected").val()}, (response) ->
			#niveaus = ["wit", "groen", "geel", "oranje", "rood", "blauw"]
			erorr = response.error
			niveaus = response.niveaus
			colors = response.colors
			console.log(niveaus)
			options = window.chart_ffdfd.options 
			options.colors = colors
			type = $('button[name="chart_type"].active').val()
			if type == "column"
				console.log(response.freqs)
				options.series[0].data = to_percentage(response.freqs)
				console.log(response.freqs2)
				options.series[1].data = to_percentage(response.freqs2)
			else
				options.series[0].data = response.freqs
				options.series[1].data = response.freqs2
			options.series[0].type = type
			options.series[1].type = type
			if type == "pie"
				if $('#schools1').find(":selected").val() == "" || $('#schools2').find(":selected").val() == ""
					if $('#schools1').find(":selected").val() != ""
						options.series[0].center = [500,160]
						options.series[0].size = '80%'
						options.series[1].center = [2000,120]
					else
						if $('#schools2').find(":selected").val() != ""
							options.series[1].center = [500,160]
							options.series[1].size = '80%'
							options.series[0].center = [2000,120]
						else
							options.series[0].center = [2000,120]
							options.series[1].center = [2000,120]
				else
					options.series[0].center = [300,160]
					options.series[1].center = [730,160]
					options.series[0].size = '70%'
					options.series[1].size = '70%'
				options.plotOptions.pie.dataLabels = {enabled: true, formatter: ->
					return (this.percentage).toFixed(2) + ' %' + '<br />' + niveaus[this.point.x]}
			chart = new Highcharts.Chart(options)
			if type == "column"
				chart.xAxis[0].update({categories:niveaus}, true)
				chart.tooltip.options.formatter = -> 
					# differentieren met this.series.name
					if this.series.name == "zwemmers"
						return response.freqs[(jQuery.inArray(this.x, niveaus))]
					else
						return response.freqs2[(jQuery.inArray(this.x, niveaus))]
			else
				chart.tooltip.options.formatter = -> 
					return this.y
			if $('#schools1').find(":selected").val() == "" && $('#schools2').find(":selected").val() == "" 
				chart.setTitle({text: "Selecteer een school en klas"})
			else
				chart.setTitle({text: response.title})
			if $('#schools1').find(":selected").val() == ""
				chart.series[0].hide()
			else
				chart.series[0].show()
			if $('#schools2').find(":selected").val() == ""
				chart.series[1].hide()
			else
				chart.series[1].show()
			# volgende lijn voor vanaf lazy_high_charts 1.4.2
			window.chart_ffdfd = chart
			$('#spinner').hide())
	$("#userinvoer").attr("disabled", "disabled")
	$(".import_submit").attr("disabled", "disabled")
	$(document).on("click", ".area_wijzig", ( ->
		row = $(this).parent().closest('tr')
		row_index = $("#autotafel tr").index(row)
		textarea_value = $("#userinvoer").val()
		naam = textarea_value.split("\n")[row_index-1]
		correcte_naam = row.children("td:eq(2)").text().replace("Wijzig", "")
		correcte_naam = correcte_naam.substr(0, correcte_naam.indexOf("("))
		$("#userinvoer").val(textarea_value.replace(naam, correcte_naam))
		console.log(naam)
		console.log(correcte_naam)
		redraw_autotafel()))
	$(document).on("click", ".import_wijzig", ( ->
		console.log($(this).parent().prev('td').text())
		row = $(this).parent().closest('tr')
		name = $(this).parent().prev('td').text().replace("Wijzig", "")
		$.get('import_wijzig', {zwemmer: $(this).attr('id'), naam: name}, (response) ->
			console.log(name)
			antwoord = jQuery.parseJSON(response.succes)
			niveau_kleur = response.kleur
			naam = response.naam
			klas = response.klas
			if antwoord == true
				console.log(niveau_kleur)
				name_ruw = row.children("td:eq(2)").text()
				row.children("td:eq(1)").html(naam + klas)
				row.children("td:eq(2)").html("")
				row.children("td:eq(0)").html("<i class=\"icon-ok\"></i>")
				row.css("background-color", niveau_kleur)
			console.log(antwoord))))
	$('#autotafel').hide()
	$('#klas').change ->
		if parseInt(this.value) > 0
			$("#userinvoer").attr("disabled", false)
	check_all = ->
		ret_draw = false
		if (parseInt($('#klas').val()) > 0) && (parseInt($('#niveau').val()) > 0)
			console.log("hier")
			$('#userinvoer').attr("disabled", false)
			if $("#userinvoer").val() != ""
				$('#import_submit').attr("disabled", false)
				ret_draw = true
			else
				$('#import_submit').attr("disabled", "disabled")
		else
			$('#import_submit').attr("disabled", "disabled")
			$('#userinvoer').attr("disabled", "disabled")
		return ret_draw
	$('#klas').change ->
		#check_select_inputs()
		#check_area_input()
		check_all()
	$('#niveau').change ->
		ret = check_all()
		#ret = check_select_inputs()
		#console.log(ret)
		if ret == true
			redraw_autotafel()
			#check_area_input()
	$('#userinvoer').bind 'input propertychange', () ->
		redraw_autotafel()
		#check_area_input()
		check_all()
	$('button[name="chart_jaar1"]').click ->
		injaar1 = $(this).attr('value')
		adjust_stat_file_link(1)
		get_and_draw()
	$('button[name="chart_jaar2"]').click ->
		injaar2 = $(this).attr('value')
		adjust_stat_file_link(2)
		get_and_draw()
	#$('#stat_schools').change ->
	$('select[name="schools"]').change ->
		school_select_nr = $(this).attr('id').substr($(this).attr('id').length-1)
		if $(this).val() == ""
			$("button[name=\"chart_jaar#{school_select_nr}\"]").prop('disabled', 'disabled')
			$("#pictures#{school_select_nr}").attr("disabled", "disabled")
			$("#stat_pdf#{school_select_nr}").attr("disabled", "disabled")
			$("#stat_exc#{school_select_nr}").attr("disabled", "disabled")
			school_active_counter -= 1
			get_and_draw()
		else
			$("button[name=\"chart_jaar#{school_select_nr}\"]").prop('disabled', false)
			$("#pictures#{school_select_nr}").attr("disabled", false)
			$("#stat_pdf#{school_select_nr}").attr("disabled", false)
			$("#stat_exc#{school_select_nr}").attr("disabled", false)
			school_active_counter += 1
			adjust_stat_file_link(school_select_nr)
			get_and_draw()
		if (school_active_counter == 2)
			$("#stat_pdf_comp").attr("disabled", false)
			$("#stat_exc_comp").attr("disabled", false) 
		else
			$("#stat_pdf_comp").attr("disabled", "disabled")
			$("#stat_exc_comp").attr("disabled", "disabled") 
	$('select[name="pictures"]').change ->
		console.log($('.comp_pdf').attr('href'))
		url = '/fronts/picture_calc?format2=pdf&picture1='+$('#pictures1').find(":selected").val()+'&picture2='+ $('#pictures2').find(":selected").val() 
		$('.comp_pdf').attr('href', url)
		get_and_draw()
	$('button[name="chart_type"]').click ->
		get_and_draw()
	$('li.stat_pill').click ->
		$('li.stat_pill').each ->
      		$(this).removeClass("active")
      	$(this).addClass("active")
		$('.stat_div').each ->
			$(this).hide()
		console.log("#{$(this).attr('id')}")
		$("div##{$(this).attr('id')}").show()
	active_sides =  ->
		sides = []
		if $('#schools1').find(":selected").val() != "" || $('#schools2').find(":selected").val() != "" 
			if $('#schools1').find(":selected").val() != ""
				sides.push 1
			if $('#schools2').find(":selected").val() != ""
				sides.push 2
		return sides
	single_jaar_table = (school) ->
		$("#single_table").find("tr:gt(0)").remove()
		$.get('getstat', {jaar1: injaar1,jaar2: injaar2, school1: $('#schools1').find(":selected").val(), school2: $('#schools2').find(":selected").val(),}, (response) ->
			console.log(response)
			side = active_sides()
			niveaus = response.niveaus
			if side[0] == 1
				freqs = response.freqs
			else
				freqs = response.freqs2
			i = 0
			perc = to_percentage(freqs)
			console.log(perc)
			for k,f of freqs
				console.log(f)
				cellen = "<td>" + niveaus[i] + "</td>" + "<td>" + f + "</td>" + "<td>" + perc[i] + "</td>"
				$('#single_table tbody').append("<tr>" + cellen + "</tr>")
				i += 1)
	$('#comp_pill').click ->
		ret = active_sides()
		single_jaar_table()
		$("#comp_table").find("tr:gt(0)").remove();
		$.get('picture_calc', {picture1: $('#pictures1').find(":selected").val(), picture2: $('#pictures2').find(":selected").val()}, (response) ->
			rijen = jQuery.parseJSON(response.comp.rows)
			color = ""
			console.log(response.colors)
			kleuren = jQuery.parseJSON(response.colors)
			console.log(response)
			for rij in rijen
				cellen = ""
				for cel in rij
					cellen += "<td>" + cel + "</td>"
					console.log(cel)
				color = if (rij[1] == "") then color else kleuren[rij[1]]
				$('#comp_table tbody').append("<tr style=\"background-color:#{color};\">" + cellen + "</tr>"))
###
	$(document)
    	.ajaxStart ->
        	$('.laaddiv h5').html("Loading---")
    	.ajaxStop ->
        	$('.laaddiv h5').html("")
###