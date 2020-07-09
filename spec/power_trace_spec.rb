RSpec.describe PowerTrace do
  class Promotion; end
  class Order; end
  class Cart
    def total
      10
    end
    def promotion
      Promotion.new
    end
  end
  class CartOperationService
    def perform(cart)
      validate_cart(cart)
      apply_discount(cart)
      create_order(cart)
    end

    def validate_cart(cart)
      cart.total
      cart
    end

    def apply_discount(cart)
      cart.promotion
      cart
    end

    def create_order(cart)
      Order.new
      a_method_with_block do |one|
        inspect_method
      end
    end

    def a_method_with_block
      yield
    end

    def inspect_method
      puts(power_trace)
    end
  end
  it "has a version number" do
    expect(PowerTrace::VERSION).not_to be nil
  end

  it "does something useful" do
    CartOperationService.new.perform(Cart.new)
  end
end
