# name: discourse-topic-trade-buttons

# about: Adds one or all buttons (Sold, Purchased, expired) to designated categories

# version: 0.0.1

# authors: Janno Liivak



enabled_site_setting :topic_trade_buttons_enabled



PLUGIN_NAME ||= "discourse_topic_trade_buttons".freeze



after_initialize do



  if SiteSetting.topic_trade_buttons_enabled then



    add_to_serializer(:topic_view, :category_enable_sold_button, false) {

      object.topic.category.custom_fields['enable_sold_button'] if object.topic.category

    }



    add_to_serializer(:topic_view, :category_enable_purchased_button, false) {

      object.topic.category.custom_fields['enable_purchased_button'] if object.topic.category

    }



    add_to_serializer(:topic_view, :category_enable_expired_button, false) {

      object.topic.category.custom_fields['enable_expired_button'] if object.topic.category

    }



    add_to_serializer(:topic_view, :category_enable_cancelled_button, false) {

      object.topic.category.custom_fields['enable_cancelled_button'] if object.topic.category

    }



    add_to_serializer(:topic_view, :custom_fields, false) {

      object.topic.custom_fields

    }



  end



  module ::DiscourseTopicTradeButtons

    class Engine < ::Rails::Engine

      engine_name PLUGIN_NAME

      isolate_namespace DiscourseTopicTradeButtons

    end

  end



  class DiscourseTopicTradeButtons::Trade

    class << self



      def sold(topic_id, user)

        trade('sold', topic_id, user)

      end



      def purchased(topic_id, user)

        trade('purchased', topic_id, user)

      end



      def expired(topic_id, user)

        trade('expired', topic_id, user)

      end



      def cancelled(topic_id, user)

        trade('cancelled', topic_id, user)

      end



      def trade(transaction, topic_id, user)

        DistributedMutex.synchronize("#{PLUGIN_NAME}-#{topic_id}") do

          user_id = user.id

          topic = Topic.find_by_id(topic_id)



          # topic must not be deleted

          if topic.nil? || topic.trashed?

            raise StandardError.new I18n.t("topic.topic_is_deleted")

          end



          # topic must not be archived

          if topic.try(:archived)

            raise StandardError.new I18n.t("topic.topic_must_be_open_to_edit")

          end



          topic.archived = true

          i18n_transaction = I18n.t("topic_trading.#{transaction}", locale: (SiteSetting.default_locale || :en)).mb_chars.upcase

          topic.title = "[#{i18n_transaction}] #{topic.title}"

          topic.custom_fields["#{transaction}_at"] = Time.zone.now.iso8601

          topic.save!



          return topic

        end

      end



    end

  end



  require_dependency "application_controller"



  class DiscourseTopicTradeButtons::TradeController < ::ApplicationController

    requires_plugin PLUGIN_NAME



    before_action :ensure_logged_in



    def sold

      topic_id   = params.require(:topic_id)



      begin

        topic = DiscourseTopicTradeButtons::Trade.sold(topic_id, current_user)

        render json: { topic: topic }

      rescue StandardError => e

        render_json_error e.message

      end

    end



    def purchased

      topic_id   = params.require(:topic_id)



      begin

        topic = DiscourseTopicTradeButtons::Trade.purchased(topic_id, current_user)

        render json: { topic: topic }

      rescue StandardError => e

        render_json_error e.message

      end

    end



    def expired

      topic_id   = params.require(:topic_id)



      begin

        topic = DiscourseTopicTradeButtons::Trade.expired(topic_id, current_user)

        render json: { topic: topic }

      rescue StandardError => e

        render_json_error e.message

      end

    end



    def cancelled

      topic_id   = params.require(:topic_id)



      begin

        topic = DiscourseTopicTradeButtons::Trade.cancelled(topic_id, current_user)

        render json: { topic: topic }

      rescue StandardError => e

        render_json_error e.message

      end

    end



  end



  DiscourseTopicTradeButtons::Engine.routes.draw do

    put "/sold" => "trade#sold"

    put "/purchased" => "trade#purchased"

    put "/expired" => "trade#expired"

    put "/cancelled" => "trade#cancelled"

  end



  Discourse::Application.routes.append do

    mount ::DiscourseTopicTradeButtons::Engine, at: "/topic"

  end



end
