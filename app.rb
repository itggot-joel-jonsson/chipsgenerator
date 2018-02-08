class App < Sinatra::Base
	
	enable :sessions

	db = SQLite3::Database.new("db/chips_and_dip.sqlite")

	post('/random') do
		all_chips = db.execute("SELECT id FROM chips")
		antal = all_chips.size + 1
		session[:chips_id] = rand(1...antal)
		contains_milk = [1]
		contains_snacks = [1]
		if session[:snacks] != 1
			while contains_snacks.join.to_i == 1
				session[:chips_id] = rand(1...antal)
				contains_snacks = db.execute("SELECT snacks FROM chips WHERE id IS '#{session[:chips_id]}'")
			end
		end
		if session[:nomilk] == 1 && session[:snacks] != 1
			while contains_milk.join.to_i == 1 || contains_snacks.join.to_i == 1
				session[:chips_id] = rand(1...antal)
				contains_milk = db.execute("SELECT mjolk FROM chips WHERE id IS '#{session[:chips_id]}'")
				contains_snacks = db.execute("SELECT snacks FROM chips WHERE id IS '#{session[:chips_id]}'")				
			end
		end
		if session[:nomilk] == 1 && session[:snacks] == 1
			while contains_milk.join.to_i == 1
				session[:chips_id] = rand(1...antal)
				contains_milk = db.execute("SELECT mjolk FROM chips WHERE id IS '#{session[:chips_id]}'")
			end
		end
		redirect("/")
	end

	post('/diprandom') do
		all_dips = db.execute("SELECT id FROM dip")
		antal = all_dips.size + 1
		session[:dip_id] = rand(1...antal)
		contains_milk = [1]
		if session[:nomilk] == 1
			while contains_milk.join.to_i == 1
				session[:dip_id] = rand(1...antal)
				contains_milk = db.execute("SELECT mjolk FROM dip WHERE id IS '#{session[:dip_id]}'")
			end
		end
		redirect("/")
	end
	
	get('/') do
		if session[:rated] == nil
			session[:rated] = []
		end
		result = db.execute("SELECT * FROM chips WHERE id IS '#{session[:chips_id]}'")
		allratings = db.execute("SELECT betyg FROM betyg_table WHERE produkt_id IS '#{session[:chips_id]}'")
		if allratings.size != 0
			rating = 0
		 	allratings.each do |rate|
		 		rating += rate.join.to_f
		 	end
			 betyg = (rating/(allratings.size))
			 db.execute("UPDATE chips SET betyg=? WHERE id=?", [betyg, session[:chips_id]])			 
		else betyg = "Ej betygsatt" 
		end
		max_betyg = db.execute("SELECT MAX(betyg) FROM chips")
		max_chips = db.execute("SELECT * FROM chips WHERE betyg=?", [max_betyg])
		resultdip = db.execute("SELECT * FROM dip WHERE id IS '#{session[:dip_id]}'")
		slim(:index, locals:{ chipsinfo:result[0], rating:betyg, rated:session[:rated], votes:allratings.size, nomilk:session[:nomilk], snacks:session[:snacks], top_rated:max_chips[0], dipinfo:resultdip[0]})
	end

	post('/rate') do
		rating = params["rating"]
		if rating.to_i <= 10
			if rating.to_i >= 0
				db.execute("INSERT INTO betyg_table('produkt_id', 'betyg') VALUES(?, ?)", [session[:chips_id], rating])
				session[:rated]<<session[:chips_id]
			end
		end
		redirect("/")
	end

	post('/milk') do
		if session[:nomilk] != 1
			session[:nomilk] = 1
		else
			session[:nomilk] = 0
		end
		redirect("/")
	end

	post('/snacks') do
		if session[:snacks] != 1
			session[:snacks] = 1
		else
			session[:snacks] = 0
		end
		redirect("/")
	end

end           
