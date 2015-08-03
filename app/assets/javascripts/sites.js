$(document).ready(function(){

  console.log("sites.js up!");

  $('body').on('click','.del-results', function(e){
    e.preventDefault();
    appStorage.clearStorage();
    appStorage.listStorage();
  });

  $('body').on('click', '.stored', function(e){
    e.preventDefault();
    var result = localStorage.getItem($(e.target).attr('data-z'));
    showResult(JSON.parse(result));
  });

  $('.sign-in').on('click', function(e){
    $('.call').toggleClass('hidden');
    $('#signin').toggleClass('hidden');
  });

  $('body').on('click', '.sign-up', function(e){
    $('.call').toggleClass('hidden');
    $('#signup').toggleClass('hidden');
  });

  $('body').on('click', '.show-user', function(e){
    $('.edit-user').toggleClass('hidden');
  });


  $('body').on('click', '.result-toggle', function(e){
    e.preventDefault();
    var content = $(e.target).text();
    if (content.indexOf('Hide') >= 0) {
      $(e.target).text(content.replace('Hide', 'Show'));
    } else{
      $(e.target).text(content.replace('Show', 'Hide'));
    }

    $(e.target).parent('p').next('div').toggleClass('hidden');
  }); //end of show-hide link event handler

  $(".search-form").on("submit", function(e){
    e.preventDefault();
    fData = $(this).serializeArray();
    //I have chosen not to make the inputs blank here because I think 
    //most people would want to make minor changes to see how affordabillty
    //changes rather than start fresh each time.

    $.ajax({
      url:$(this).attr("action"),
      type:"POST",
      dataType: "json",
      data: fData,
      success: function(data){
        // console.log(data);
        
        showResult(data);
        appStorage.storeResult(data);
        appStorage.listStorage();
      },
      error: function(data){
        // console.log(data);
        showResult(data, true);
      }
    });// end of ajax call

  });

  //add result to DOM
  function showResult(data, isError) {
    $('#search-result, #search-result p, #search-result div').removeClass('hidden');
    $('#entry-error').remove();
    //$("#search-result p").reClass('hidden');
    if(isError){
      var msg = JSON.parse(data.responseText);
      console.log(msg.error);
      $("#search-result p, #search-result div").addClass('hidden');
      $("#search-result").append(
        '<p id="entry-error" class="alert alert-warning">Request Failed: ' + msg.error + '</p>'
        );
    } else {
      var result = new Result(data);
      result.genRequest();
      result.genResponse();
      result.genAmortization();
    }
    //scroll to #search-result
    $(window).scrollTop($("#search-result").position().top);
    // body...
  }

  //object to store the last 15 searches in local storage and retrieve them on click
  function ResultStorage(){
    this.resultsArray = [];
    //ZMA => Zillow Mortgage Affordability

    for (var i = 0; i < 15; i++) {
      var key = "ZMA" + i, value = localStorage.getItem(key);
      if(value){
        this.resultsArray.push(key);
      }
    }
  }
  ResultStorage.prototype.clearStorage = function(){
    localStorage.clear();
    this.resultsArray = [];
    return;
  };
  ResultStorage.prototype.listStorage = function(){
      $('#prev-search .del-results').parent('p').remove();
      $('#prev-search ul').empty();
      if(this.resultsArray.length < 1) {return;}
    this.resultsArray.forEach(function(k,i) {
      var value = JSON.parse(localStorage.getItem(k));
      var content = ["Affordable Mortgage: $", parseInt(value.response.affordabilityAmount).toLocaleString(),
      "Monthly Mortgage Desired: $", value.request.monthlypayment];
      var line = "<li class='list-group-item'>" + makeEl("p", "col-md-4",content[0] + content[1]) +
      makeEl("p", "col-md-4",content[2] + content[3]) + " <a href='#' class='stored' data-z='" + k + "'>show</a><li/>";
      $('#prev-search ul').append(line);
    });
    $('#prev-search').append(makeEl("p","","<a href='#' class='del-results'>Clear All</a>"));
    return;
  };
  ResultStorage.prototype.storeResult = function(rdata){
    var capacity = this.resultsArray.length, value = JSON.stringify(rdata);

    if(capacity > 0){
      var duplicate = false;
      this.resultsArray.forEach(function(r) {
        duplicate = value === localStorage.getItem(r);
      });
      if(duplicate){return;}
    }

    if(capacity < 15){
      //store
      localStorage.setItem("ZMA" + capacity, value);
      this.resultsArray.push("ZMA" + capacity);
    } else {
      //remove the first and add to the end
      //need to figure out a more efficient way to preserve order
      for (var i = 0; i < 15; i++) {
        if(i === 14){
          localStorage.setItem("ZMA" + 1, value);
          break;
        }
        localStorage.setItem("ZMA" + i, localStorage.getItem("ZMA" + (i + 1)));
      }
    }
    return;
  };

  ResultStorage.prototype.getShowResult = function(key){
    var result = localStorage.getItem(key);
    showResult(result);
  };

  //object to process result data from zillow
  function Result(rdata){
    this.rdata = rdata;
  }

  Result.prototype.genRequest = function(){

    //request parameter display

    $("#search-result .request").empty();
    $("#search-result .request").show();
    $("#search-result .request").append("<h3 class='col-md-12'>Parameters</h3>");
    var req = this.rdata.request, parameters = "";
    var reqCats = [["Annual Income: $", req.annualincome], ["Monthly Mortgage Desired: $", req.monthlypayment],
    ["Expected Down Payment: $", req.down], ["Current Monthly Debt: $", req.monthlydebts], ["Expected Interest Rate: ", req.rate],
    ["Amortization Schedule: ", req.schedule], ["Desired Mortgage Term: ", req.terminmonths], ["Debt to Income Ratio: ", req.debttoincome],
    ["Estimated Tax Rate: ", req.incometax], ["Desired Zipcode: ", req.zipcode], ["Hazard Insurance Premium: $", req.hazard],
    ["PMI Premium: $", req.pmi], ["Property Tax: $", req.propertytax], ["Monthly HOA Fees: $", req.hoa]
    ];

    reqCats.forEach(function(cat){
      if(cat[1] && cat[1] !== '0'){
        parameters = makeEl("span", "label label-info", cat[0] + parseInt(cat[1]).toLocaleString());
        if(cat[0] === "Desired Mortgage Term: "){
          parameters = makeEl("span", "label label-info", cat[0] + cat[1] + " months");
          $("#search-result .request").append(parameters);
        } else if(cat[0] === "Expected Interest Rate: " || cat[0] === "Debt to Income Ratio: " || cat[0] === "Estimated Tax Rate: ") {
          parameters = makeEl("span", "label label-info", cat[0] + cat[1] + "%");
          $("#search-result .request").append(parameters);
        } else {
          $("#search-result .request").append(parameters);
        }
        
        if($('#search-result .request .label').length % 3 === 0){
          $("#search-result .request").append("<br>");
        }

      }
    });
    
    return;

  };

  Result.prototype.genResponse = function(){
    //Display Response
    $("#search-result .response ul").empty();
    $("#search-result .response h3").remove();
    $("#search-result .response").prepend("<h3>Affordability Estimates</h3>"+
      "<p>Given the about parameters, your affordability estimates are stated below:</p>");
    var resp = this.rdata.response, temp;
    var respCats = [["Affordable Mortgage:", resp.affordabilityAmount], ["Monthly Income:", resp.monthlyIncome],
    ["Monthly Income Tax:", resp.monthlyIncomeTax], ["Other Monthly Debts:", resp.monthlyDebts],
    ["Monthly Mortgage Principal & Interest:", resp.monthlyPrincipalAndInterest], ["Monthly Property Tax:", resp.monthlyPropertyTaxes],
    ["Monthly PMI:", resp.monthlyPmi],["Monthly Hazard Insurance Premium:", resp.monthlyHazardInsurance],
    ["Monthly HOA Fees:", resp.monthlyHoaDues], ["Monthly Remaining Income:", resp.monthlyRemainingBudget],
    ["Total Monthly Payment:", resp.totalMonthlyPayment], ["Total Taxes, Fees and Premiums:", resp.totalTaxesFeesAndInsurance], 
    ["Total Interest Payments:", resp.totalInterestPayments], ["Total Principal:", resp.totalPrincipal],
    ["Total Payments:", resp.totalPayments]
    ];

    respCats.forEach(function(cat){
      if(cat[1] && cat[1] !== "0"){
        var catParagraphs = makeEl("p", "col-md-4", cat[0]) + makeEl("p", "col-md-2 text-center", "$" + parseInt(cat[1]).toLocaleString());
        if(cat[0] === "Affordable Mortgage:"){
          catParagraphs = makeEl("p", "col-md-4 lead", cat[0]) + makeEl("p", "col-md-2 text-center lead", "$" + parseInt(cat[1]).toLocaleString());
        }
        temp = makeEl("li", "row list-group-item", catParagraphs);
        $("#search-result .response ul").append(temp);
      }
    });
    return;

  };

  Result.prototype.genAmortization = function(){
    //display amortization
    $("#search-result .amortization ul, #search-result .amortization h3").remove();
    $("#search-result .amortization").append("<h3>Amortization Schedule</h3>");
    var resp = this.rdata.response;
    var both = resp.annualAmortizationSchedule && resp.monthlyAmortizationSchedule;
    var schedule = both ? [resp.annualAmortizationSchedule, resp.monthlyAmortizationSchedule] : 
    [resp.annualAmortizationSchedule || resp.monthlyAmortizationSchedule];
    schedule.forEach(function(sch){
      var amTitle = sch === resp.annualAmortizationSchedule ? "Annual Amortization Table" : "Monthly Amortization Table";
      $("#search-result .amortization").append("<h4>" + amTitle +"</h4>");
      var headers = Result.prototype.amLine("<b>Period</b>", "<b>Beg Balance</b>", "<b>Amount</b>", "<b>Interest</b>", "<b>Principal</b>", "<b>End Balance</b>");
      
      $("#search-result .amortization").append("<ul>" + headers + "</ul>");
      sch.forEach(function(p){
        var line = Result.prototype.amLine(p.period, "$" + parseInt(p.beginningBalance).toLocaleString(), "$" + parseInt(p.amount).toLocaleString(),
         "$" + parseInt(p.interest).toLocaleString(), "$" + parseInt(p.principal).toLocaleString(), "$" + parseInt(p.endingBalance).toLocaleString());
        $("#search-result .amortization ul").last().append(line);
      });

    });

    $("#search-result .amortization").addClass("hidden");
    return;
  };

  //to keep amortization processing DRY
  Result.prototype.amLine = function(period,begin,amount,interest,principal,ending){
    return "<li><p class='col-md-2 text-center'>" + period +"</p><p class='col-md-2 text-center'>" + begin + "</p>" + 
        "<p class='col-md-2 text-center'>" + amount + "</p><p class='col-md-2 text-center'>" + interest + "</p>" +
        "<p class='col-md-2 text-center'>" + principal + "</p><p class='col-md-2 text-center'>" + ending + "</p></li>";
  };

  //making html elements
  function makeEl(tag, tclass, content){
    return "<" + tag +" class='" + tclass + "''>" + content + "</" + tag + ">";
  }

  var appStorage = new ResultStorage();
  appStorage.listStorage();
});

// $(document).on("page: load", function(){
//   console.log("sites.js up!");
// });
