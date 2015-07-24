class Prospect < ActiveRecord::Base
  #require 'json' #for storing zillow parameter hash in json format

  has_many :searches
  has_many :users, through: :searches

  def self.gen_zillow_parameters params_hash
    h1 = params_hash.reject { |k, v| k == "utf8" || k == "authenticity_token" || k == "commit"}
    parameters = h1.merge({ "zws-id" => ENV["zillow_web_id"], output: "json" })
    parameters["term"] = parameters["term"].to_i * 12
    parameters["estimate"] = true if parameters["estimate"] == "1"

    parameters
  end

  def set_parameters p_hash
    neu_hash = p_hash.reject{|k,v| k == "zws-id"}
    self.parameters = neu_hash.to_s
  end

  def parameters_hash
    JSON.parse(self.parameters)
  end

  
end
