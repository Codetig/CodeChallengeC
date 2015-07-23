class Prospect < ActiveRecord::Base
  require 'json' #for storing zillow parameter hash in json format

  has_many :searches
  has_many :users, through: :searches

  def self.get_prospect p_hash
    prospect = Prospect.where(parameters: p_hash.to_json)
    prospect.length > 0 ? prospect[0] : prospect
  end

  def self.gen_zillow_parameters params_hash
    h1 = params_hash.reject { |k, v| k == "utf8" || k == "authenticity_token" || k == "commit"}
    parameters = h1.merge({ "zws-id" => ENV["zillow_web_id"], output: "json" })
    parameters["term"] = parameters["term"].to_i * 12
    parameters["estimate"] = true if parameters["estimate"] == "1"

    parameters
  end

  def set_basic_prospect p_hash
    self.basic_prospect = false
    p = [p_hash["rate"],p_hash["schedule"],p_hash["term"],p_hash["debttoincome"],p_hash["incometax"],p_hash["estimate"],
    p_hash["zip"],p_hash["hazard"],p_hash["pmi"],p_hash["propertytax"],p_hash["hoa"]]
    c = ["","yearly",360,"36","30",nil,"","","","","0"]
    self.basic_prospect = true if  p == c
    
  end

  def set_parameters p_hash
    p_hash["term"] = (p_hash["term"] / 12).to_s
    p_hash["estimate"] = "1" if p_hash["estimate"]
    j_hash = p_hash.reject{|k,v| k == "zws-id"}.to_json.to_json #why two???
    self.parameters = j_hash
  end

  def parameters_hash
    JSON.parse(self.parameters)
  end

  
end
