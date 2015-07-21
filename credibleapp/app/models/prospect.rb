class Prospect < ActiveRecord::Base
  require 'json' #for storing zillow parameter hash in json format

  has_many :searches
  has_many :users, through: :searches

  def self.gen_zillow_parameters params_hash
    h1 = params_hash.reject { |k, v| k == "utf8" || k == "authenticity_token" || k == "commit"}
    parameters = h1.merge({ "zws-id" => ENV["zillow_web_id"], output: "json" })
    parameters["term"] = parameters["term"].to_i * 12
    parameters
  end

  def set_parameters p_hash
    self.basic_prospect = false
    p = [p_hash["rate"],p_hash["schedule"],p_hash["term"],p_hash["debttoincome"],p_hash["incometax"],p_hash["estimate"],
    p_hash["zip"],p_hash["hazard"],p_hash["pmi"],p_hash["propertytax"],p_hash["hoa"]]
    c = ["","none",360,"36","30",nil,"","","","","0"]
    self.basic_prospect = true if  p == c
    self.parameters = p_hash.to_json #why does this not work!?!
  end

  def parameters_hash
    JSON.parse(self.parameters)
  end
end
