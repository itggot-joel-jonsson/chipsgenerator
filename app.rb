class App < Sinatra::Base
	
	enable :sessions

	db = SQLite3::Database.new("db/chips_and_dip.sqlite")

	post('/random') do
		all_chips = db.execute("SELECT id FROM chips")
		antal = all_chips.size + 1
		session[:chips_id] = rand(1...antal)
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
		else betyg = "Ej betygsatt" 
		end
		slim(:index, locals:{ chipsinfo:result[0], rating:betyg, rated:session[:rated], votes:allratings.size, nomilk:session[:nomilk], snacks:session[:snacks]})
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
