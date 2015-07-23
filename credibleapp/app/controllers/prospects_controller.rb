class ProspectsController < ApplicationController

  def search #will need to use typheous here
    basic_params = ["annualincome", "monthlypayment", "down", "monthlydebts"]
    s = 0
    basic_params.each{|p| s += 1 if params[p].to_i > 0}
    # result = ""

    if (s > 2)
      parameters = Prospect.gen_zillow_parameters(params)
      p1 = Prospect.new
      
      request = Typhoeus::Request.new(
      "http://www.zillow.com/webservice/mortgage/CalculateAffordability.htm",
      params: parameters,
      followlocation: true
      )
      request.run
      
      if request.response.success?
        p1.set_basic_prospect(parameters)
        p1.set_parameters(parameters)
        p1.zillow_result = request.response.response_body.to_json
        p1.save if p1.basic_prospect
        result = JSON.parse(p1.zillow_result)

        respond_to do |format|
          format.html {render "sites/index.html.erb"} #{render "show.html.erb"}
          format.json {render :json => result, status: 200}
        end

        puts("All went well!!!")
      else
        render :json => {error: "Request could not be processed"}, status:400
      end
    else
      render :json => {error: "There were missing parameters"}, status: 412 #pre-condition failed
    end
    # binding.pry #binding pry 
  end

  def show
  end

  private
  def prospect_params #is this needed
    # params.require(:prospect).permit(:)
  end

end

# Parameters: {"utf8"=>"✓", "authenticity_token"=>"0ySSem0rCapiJdgEkdnIQOEXhiStRcoPvwJtOyspfRli6vjz+4C+wm6G6tepw0rgEbBE3yeoKwF4EOIOMPkBcw==", "annual_income"=>"50000", "monthlypayment"=>"", "down"=>"20000", "monthlydebts"=>"1000", "rate"=>"", "schedule"=>"none", "term"=>"30", "debttoincome"=>"36", "incometax"=>"30", "zip"=>"", "hazard"=>"", "pmi"=>"", "propertytax"=>"", "hoa"=>"0", "commit"=>"Estimate"}
