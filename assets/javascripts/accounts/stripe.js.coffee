App.PurchaseFormController = Ember.Controller.extend
  apiKey: 'sk_test_GSKmCIsYPW9tjrTtTHdL7MTm',
  key: 'pk_test_CRzkpHAchGeztE2X3htRv5M5'
  
  processingPurchase: false
  
  number: null
  cvc: null
  exp: null
  expMonth: (->
    if @get("exp")
      return Ember.$.payment.cardExpiryVal(@get("exp")).month

    "MM"
  ).property("exp")
  expYear: (->
    if @get("exp")
      return Ember.$.payment.cardExpiryVal(@get("exp")).year
    "YYYY"
  ).property("exp")

  
  price: 10
  description: "Dem Widgets"
  
  purchase: ->
    @set('processingPurchase', true)
    
    Stripe.setPublishableKey(@get('key'));
    
    Stripe.card.createToken({
      number: @get('number')
      cvc: @get('cvc')
      exp_month: @get('expMonth')
      exp_year: @get('expYear')
    }, @didCreateToken.bind(this))
 
  didCreateToken: (status, response) ->
    if response.errors
      @set('processingPurchase', false)
      @set('errors', response.error.message)
    else
      @postCharge(response.id)
  
  postCharge: (token) ->
    this.ajax("https://api.stripe.com/v1/charges", {
       amount: @get('price') * 100
       currency: 'USD'
       card: token
       description: @get('description')
    }).then(@didPurchase.bind(this), @purchaseDidError.bind(this));

  didPurchase: ->
    alert('Purchased!')
    @set('processingPurchase', false)
    
  purchaseDidError: (error) ->
    @set('errors', error.responseJSON.error.message)
    @set('processingPurchase', false)
    
    throw error
       
  ajax: (url, data) ->
    controller = this

    new Ember.RSVP.Promise (resolve, reject) ->
      hash = {}
      hash.url = url
      hash.type = 'POST'
      hash.context = controller
      hash.data = data
      
      hash.beforeSend = (xhr) ->
        xhr.setRequestHeader("Authorization", "Bearer #{controller.get('apiKey')}")
     
      hash.success = (json) ->
        resolve(json)

      hash.error = (jqXHR, textStatus, errorThrown) ->
        reject(jqXHR)

      Ember.$.ajax(hash)

  
App.PurchaseForm = Ember.View.extend 
  processingPurchase: Ember.computed.alias('controller.processingPurchase')

  

Ember.TextSupport.reopen
 attributeBindings: ["data-stripe", "autocomplete", "autocompletetype", "required"]

App.CvcField = Ember.TextField.extend
  required: true
  #pattern: "\d*"
  autocompletetype: "cc-csc"
  format: "123"
  placeholder: Ember.computed.alias("format")
  autocomplete: "off"
  didInsertElement: ->
    @$().payment("formatCardCVC")

App.CardNumberField = Ember.TextField.extend
  required: true
  #pattern: "\d*"
  autocompletetype: "cc-number"
  format: "1234 5678 9012 3456"
  placeholder: Ember.computed.alias("format")
  didInsertElement: ->
    @$().payment("formatCardNumber")

App.CardExpiryField = Ember.TextField.extend
  required: true
  autocompletetype: "cc-exp"
  format: "01 / 13"
  placeholder: Ember.computed.alias("format")
  didInsertElement: ->
    @$().payment("formatCardExpiry")
