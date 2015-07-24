class ProspectsController < ApplicationController

  def search #will need to use typheous here
    basic_params = ["annualincome", "monthlypayment", "down", "monthlydebts"]
    s = 0
    basic_params.each{|p| s += 1 if params[p].to_i > 0}
    # result = ""

    if (s > 2)
      parameters = Prospect.gen_zillow_parameters(params)
      p1 = Prospect.new
      p1.set_parameters(parameters)

      check_db = Prospect.find_by parameters: p1.parameters || false
      
      unless(check_db)
        request = Typhoeus::Request.new(
        "http://www.zillow.com/webservice/mortgage/CalculateAffordability.htm",
        params: parameters,
        followlocation: true
        )
        request.run
        
        if request.response.success?
          #p1.set_basic_prospect(parameters)
          
          p1.zillow_result = request.response.response_body.to_s
          p1.save #if p1.basic_prospect
          
        else
          render :json => {error: "Request could not be processed"}, status:400
        end
      end

      p1 = check_db if check_db
      session[:prospect_id] = p1.id if session[:user_id]

      result = JSON.parse(p1.zillow_result)
      respond_to do |format|
        format.html {render "sites/index.html.erb"} #{render "show.html.erb"}
        format.json {render :json => result, status: 200}
      end

    else
      render :json => {error: "There were missing parameters"}, status: 412 #pre-condition failed
    end
    # binding.pry #binding pry 
  end

  def update
    if (session[:user_id])
      user = User.find(session[:user_id])
      prospect = Prospect.find(session[:prospect_id]) if session[:prospect_id]
      user.prospects << prospect unless user.prospects.any?{|p| p.id == prospect.id}
      ender :json => {success: "User Updated"}, status:200
    else
      render :json => {error: "User is not signed in"}, status:412
    end
    #to be used for when users save.
  end

  private
  def prospect_params #is this needed? users do not directly make Prospects.
    # params.require(:prospect).permit(:)
  end

end