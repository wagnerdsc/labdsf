# Define the database connection to be used for this model.
connection: "looker_partner_demo"

# include all the views
include: "/views/**/*.view.lkml"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: ecommerce_etl {
  sql_trigger: SELECT max(created_at) FROM ecomm.events ;;
  max_cache_age: "24 hours"
}

persist_with: ecommerce_etl

explore: distribution_centers {}

#########  Event Data Explores #########


explore: events {
  label: "(2) Web Event Data Sa"

  join: sessions_2 {
    view_label: "Sessions"
    type: left_outer
    sql_on: ${events.session_id} =  ${sessions_2.session_id} ;;
    relationship: many_to_one
  }

  join: session_landing_page {
    view_label: "Session Landing Page"
    from: events
    type: left_outer
    sql_on: ${sessions_2.landing_event_id} = ${session_landing_page.event_id} ;;
    fields: [simple_page_info*]
    relationship: one_to_one
  }

  join: session_bounce_page {
    view_label: "Session Bounce Page"
    from: events
    type: left_outer
    sql_on: ${sessions_2.bounce_event_id} = ${session_bounce_page.event_id} ;;
    fields: [simple_page_info*]
    relationship: many_to_one
  }

  join: product_viewed {
    view_label: "Product Viewed"
    from: products
    type: left_outer
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }

  join: users {
    view_label: "Users"
    type: left_outer
    sql_on: ${sessions_2.session_user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts_2 {
    type: left_outer
    sql_on: ${users.id} = ${user_order_facts_2.user_id} ;;
    relationship: one_to_one
    view_label: "Users"
  }
}

explore: order_items {
  label: "(1) Orders, Items and Users"
  view_name: order_items

  join: inventory_items {
    view_label: "Orders"
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: users {
    view_label: "Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }
}

explore: users {}

explore: inventory_items {}

explore: products {}
