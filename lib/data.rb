module Datums

require 'date'

# http://www.ond.vlaanderen.be/infolijn/faq/schoolvakanties/

	def maak_array(start, stop, naam)
		dagen = []
		(start..stop).to_a.each {|d| dagen.push(Hash[d, naam])}
		return dagen
	end

	def jaarmarkt(huidig_jaar)	# eerste maandag van oktober
		een_oktober = Date.parse("1/10/#{huidig_jaar}")
		# vindt eerste maandag
		eerste_maandag = een_oktober + (0..6).to_a.select{|i| (een_oktober+i).wday == 1}.first
		return [{eerste_maandag => "jaarmarkt"}]
	end

	def herfst(huidig_jaar)
		een_november = Date.parse("1/11/#{huidig_jaar}")
		if een_november.wday == 0
			herfst_start = Date.parse("2/11/#{huidig_jaar}")
		else
			herfst_start = Date.parse("1/11/#{huidig_jaar}")
			# vindt begin van week
			while herfst_start.wday != 1 do
				herfst_start -= 1
			end
		end
		return maak_array(herfst_start, herfst_start+4, "herfstvakantie")
	end

	def kerst(huidig_jaar)
		december_25 = Date.parse("25/12/#{huidig_jaar}")
		case december_25.wday
		when 6
			kerst_start = december_25 + 2
		when 0
			kerst_start = december_25 + 1
		else
			kerst_start = Date.parse("25/12/#{huidig_jaar}")
			# vindt begin van week
			while kerst_start.wday != 1 do
				kerst_start -= 1
			end
		end
		return maak_array(kerst_start, kerst_start+11, "kerstvakantie")
	end

	def krokus(paas_datum)
		# 7e maandag voor pasen
		krokus_start = paas_datum - 48
		return maak_array(krokus_start, krokus_start+4, "krokusvakantie")
	end

	def pasen(huidig_jaar, paas_datum)
		if (paas_datum.month == 3)
			# 1e maandag na pasen
			pasen_start = paas_datum + 1
		else
			if (paas_datum > Date.parse("15/4/#{huidig_jaar}"))
				# 2e maandag voor pasen
				pasen_start = paas_datum - 13
			else
				# 1e maandag van april
				pasen_start = Date.parse("1/4/#{huidig_jaar}")
				while (pasen_start.wday != 1)
					pasen_start += 1
				end
			end
		end
		return maak_array(pasen_start, pasen_start+11, "paasvakantie")
	end
	def get_vakanties(huidig_jaar, huidige_maand)
		paas_data = {
			"2014" => "20/4",
			"2015" => "5/4",
			"2016" => "27/3",
			"2017" => "16/4",
			"2018" => "1/4",
			"2019" => "21/4",
			"2020" => "12/4"
		}
		paas_data.each do |k,v| 
			paas_data[k] = Date.parse(v+"/"+k) 
		end
		#huidige_maand = Date.today.strftime("%m").to_i
		if (huidige_maand > 7) 
			start_jaar = huidig_jaar
			eind_jaar = start_jaar +1
		else
			start_jaar = huidig_jaar-1
			eind_jaar = huidig_jaar
		end
		huidig_jaar = Time.now.year.to_s
		paas_datum = paas_data[eind_jaar.to_s]
		allerheiligen = [Hash[Date.parse("1/11/#{start_jaar}"), "allerheiligen"]]
		allerzielen = [Hash[Date.parse("2/11/#{start_jaar}"), "allerzielen"]]
		wapenstilstand = [Hash[Date.parse("11/11/#{start_jaar}"), "wapenstilstand"]]
		paasmaandag = [Hash[paas_datum + 1, "paasmaandag"]]
		fvdarbeid = [Hash[Date.parse("1/5/#{eind_jaar}"), "feest vd arbeid"]]
		olhhemelvaart = [Hash[paas_datum + 39, "olh hemelvaart"], Hash[paas_datum + 40, "olh hemelvaart"]]
		pinksteren = [Hash[paas_datum + 49, "pinksteren"]]
		pinkstermaandag = [Hash[paas_datum + 50, "pinkstermaandag"]]

		tussen_vak = jaarmarkt(start_jaar) + herfst(start_jaar) + allerheiligen + allerzielen + wapenstilstand + kerst(start_jaar) + krokus(paas_datum) + pasen(eind_jaar, paas_datum) + paasmaandag + fvdarbeid + olhhemelvaart + pinksteren + pinkstermaandag
		vak = {}
		tussen_vak.each {|v| v.each {|k,value| vak[k] = value}}
		return vak
	end
	def vorige_september
		huidige_maand = Date.today.month
		huidig_jaar = Date.today.year
		if huidige_maand >= 9
			last_september = Date.parse("1/09/#{huidig_jaar}")
		else
			last_september = Date.parse("1/09/#{huidig_jaar-1}")
		end
		return last_september
	end

end