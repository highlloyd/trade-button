import Topic from 'discourse/models/topic';
import { withPluginApi } from 'discourse/lib/plugin-api';
import computed from 'ember-addons/ember-computed-decorators';

function initializeWithApi(api) {

  const currentUser = api.getCurrentUser();

  Topic.reopen({
    @computed('archived', 'custom_fields.enable_sold_button')
    canTopicBeMarkedAsSold: function() {
      const enable_sold_button = (this.category_enable_sold_button)?
                                 (this.category_enable_sold_button.toLowerCase() == "true"):
                                 false;
      return !this.isPrivatemessage
        && currentUser && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_sold_button
        && !this.get('archived')
    },

    @computed('archived', 'custom_fields.enable_purchased_button')
    canTopicBeMarkedAsPurchased: function() {
      const enable_purchased_button = (this.category_enable_purchased_button)?
                                      (this.category_enable_purchased_button.toLowerCase() == "true"):
                                      false;
      return !this.isPrivatemessage
        && currentUser && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_purchased_button
        && !this.get('archived')
    },

    @computed('archived', 'custom_fields.enable_expired_button')
    canTopicBeMarkedAsExpired: function() {
      const enable_expired_button = (this.category_enable_expired_button)?
                                      (this.category_enable_expired_button.toLowerCase() == "true"):
                                      false;
      return !this.isPrivatemessage
        && currentUser && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_expired_button
        && !this.get('archived')
    },

    @computed('archived', 'custom_fields.enable_cancelled_button')
    canTopicBeMarkedAsCancelled: function() {
      const enable_cancelled_button = (this.category_enable_cancelled_button)?
                                      (this.category_enable_cancelled_button.toLowerCase() == "true"):
                                      false;
      return !this.isPrivatemessage
        && currentUser && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_cancelled_button
        && !this.get('archived')
    }

  });
}

export default {
  name: 'extend-topic-for-sold-button',
  initialize() {

    withPluginApi('0.1', initializeWithApi);

  }
}
