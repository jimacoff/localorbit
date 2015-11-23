(function() {

    var typingTimer;                //timer identifier
    var doneTypingInterval = 1000;  //time in ms, 5 second for example
    var in_str = '';

    var ProductInputMixin = {
    propTypes: {
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        unit: React.PropTypes.string.isRequired,
        unit_description: React.PropTypes.string,
        prices: React.PropTypes.array.isRequired,
        total_price: React.PropTypes.string.isRequired,
        max_available: React.PropTypes.number.isRequired,
        min_available: React.PropTypes.number.isRequired,
        cart_item_quantity: React.PropTypes.number.isRequired,
        cart_item: React.PropTypes.object.isRequired
      }).isRequired
    },

    getInitialState: function() {
      return {
        showAll: false,
        cartItemQuantity: this.props.product.cart_item_quantity > 0 ? this.props.product.cart_item_quantity : null
      };
    },

    componentDidMount: function() {
      window.insertCartItemEntry($(this.getDOMNode()));
    },

    updateQuantity: function(event) {
        var minAvail = this.props.product.min_available;
        var prodId = this.props.product.id;
        var context = this;
        var target = event.target;

        clearTimeout(typingTimer);
        if (event.keyCode == 8 || event.keyCode == 46 ) {
            $("#product-" + prodId).html("");
            $(target).removeClass('invalid-value');
        }
        else {
            in_str = in_str + String.fromCharCode(event.keyCode);
            $("#product-" + prodId).html("");
            typingTimer = setTimeout(function(){
                //do stuff here e.g ajax call etc....

                if (in_str != '0' && minAvail > 0 && in_str < minAvail) {
                    $("#product-" + prodId).html("Must order more than minimum quantity.");
                    in_str = '';
                    $(target).addClass('invalid-value');
                }
                else if (!minAvail || (in_str >= minAvail && in_str != context.state.cartItemQuantity)) {
                    $("#product-" + prodId).html("");
                    $(target).removeClass('invalid-value');
                    context.setState({cartItemQuantity: in_str});
                    $(target).trigger("cart.inputFinished");
                    in_str = '';
                }
            }, doneTypingInterval);
        }

      /*
      s = event.target.value.replace(/^0+(?=[0-9])/, '');
      setTimeout(500);

      if (s === '') {
          s = '0';
      }
      if (s != '0' && s < this.props.product.min_available) {
        $("#product-"+this.props.product.id).html("Must order more than minimum quantity.");
        s = '0';
      }
      if (s >= this.props.product.min_available) {
        $("#product-"+this.props.product.id).html("");
      }

      this.setState({cartItemQuantity: s});
      */
    },

    deleteQuantity: function() {
      var prodId = this.props.product.id;
      $("#product-" + prodId).html("");
      this.setState({cartItemQuantity: null});
      $(this.getDOMNode()).keyup();
    }
  };

  window.lo = window.lo || {};
  window.lo.ProductInputMixin = ProductInputMixin;
}).call(this);