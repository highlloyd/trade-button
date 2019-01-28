import property from 'ember-addons/ember-computed-decorators';
import Category from 'discourse/models/category';

export default {
  name: 'extend-category-for-topic-trade-buttons',
  before: 'inject-discourse-objects',
  initialize() {

    Category.reopen({

      @property('custom_fields.enable_sold_button')
      enable_sold_button: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.enable_sold_button", value);
          return value;
        }
      },

      @property('custom_fields.enable_purchased_button')
      enable_purchased_button: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.enable_purchased_button", value);
          return value;
        }
      },

      @property('custom_fields.enable_expired_button')
      enable_expired_button: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.enable_expired_button", value);
          return value;
        }
      },

      @property('custom_fields.enable_cancelled_button')
      enable_cancelled_button: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.enable_cancelled_button", value);
          return value;
        }
      }

    });
  }
};
