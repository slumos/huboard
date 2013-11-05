var CardView = Ember.View.extend({
  classNameBindings:["isClosable:closable", "stateClass"],
  isClosable: function(){
     var currentState = this.get("controller.model.current_state");

     return currentState.is_last && this.get("controller.model.state") === "open";


  }.property("controller.model.current_state","controller.model.state"),
  stateClass: function(){
     return "hb-state-" + this.get("controller.model.state");
  }.property("controller.model.current_state", "controller.model.state")

  
});

module.exports = CardView;
