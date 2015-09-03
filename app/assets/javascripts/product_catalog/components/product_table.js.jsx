//= require react-infinite-scroll.min
//= require product_catalog/product_store

(function() {

  var ProductTable = React.createClass({
    propTypes: {
      url: React.PropTypes.string.isRequired,
      cartUrl: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        hideImages: false,
        hasMore: true,
        products: []
      };
    },

    componentWillMount: function() {
      window.lo.ProductStore.listen(this.onProductsChange);
      window.lo.ProductActions.loadProducts(this.props.url);
    },

    loadMore: function() {
      window.lo.ProductActions.loadMoreProducts(this.props.url);
    },

    onProductsChange: function(res) {
      this.setState({
        products: res.products,
        hasMore: res.hasMore
      });
    },

    toggleImages: function() {
      this.setState({hideImages: !this.state.hideImages});
    },

    render: function() {
      var rows = this.state.products.map(function(product) {
        return ( <lo.ProductRow key={product.id} product={product} hideImages={this.state.hideImages} /> )
      }.bind(this));

      if(rows.length === 0 && this.state.hasMore === false) {
        rows = (<p>No products found. Try broadening your search, removing any filters, or changing your delivery date to see more results.</p>)
      }

      return (
        <div className="product-list cart_items" style={{padding: "20px"}} data-cart-url={this.props.cartUrl}>
          <InfiniteScroll
            pageStart={0}
            hasMore={this.state.hasMore}
            threshold={50}
            loadMore={this.loadMore}
            loader={(<p>Loading products....</p>)}
          >
            <div id="product-search-table" className="product-images-link row pull-right"> <a href="javscript:void(0);" onClick={this.toggleImages}><i className="font-icon" data-icon=""></i> {(this.state.hideImages) ? "Show " : "Hide "} Product Images</a> </div>
            {rows}
          </InfiniteScroll>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductTable = ProductTable;
}).call(this);