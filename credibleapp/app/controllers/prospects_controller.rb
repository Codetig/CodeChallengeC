class ProspectsController < ApplicationController

  def search #will need to use typheous here
    basic_params = ["annualincome", "monthlypayment", "down", "monthlydebts"]
    s = 0
    basic_params.each{|p| s += 1 if params[p].to_i > 0}
    # result = ""

    if (s > 2)
      parameters = Prospect.gen_zillow_parameters(params)
      request = Typhoeus::Request.new(
      "http://www.zillow.com/webservice/mortgage/CalculateAffordability.htm",
      params: parameters,
      followlocation: true
    )
    request.run
    p1 = Prospect.new
    if request.response.success?
      p1.set_parameters(parameters)
      p1.zillow_result = request.response.response_body.to_json #should I really store as a JSON or hash!?!
      p1.save if p1.basic_prospect
      result = JSON.parse(p1.zillow_result)["response"]

      puts("All went well!!!")
    else
      puts("Ohh No!!!")
    end
    end
    # binding.pry #binding pry
    redirect_to root_path
  end

  def show
  end
end

# Parameters: {"utf8"=>"✓", "authenticity_token"=>"0ySSem0rCapiJdgEkdnIQOEXhiStRcoPvwJtOyspfRli6vjz+4C+wm6G6tepw0rgEbBE3yeoKwF4EOIOMPkBcw==", "annual_income"=>"50000", "monthlypayment"=>"", "down"=>"20000", "monthlydebts"=>"1000", "rate"=>"", "schedule"=>"none", "term"=>"30", "debttoincome"=>"36", "incometax"=>"30", "zip"=>"", "hazard"=>"", "pmi"=>"", "propertytax"=>"", "hoa"=>"0", "commit"=>"Estimate"}
