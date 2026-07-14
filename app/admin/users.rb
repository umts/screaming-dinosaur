# frozen_string_literal: true

ActiveAdmin.register User do # rubocop:disable Metrics/BlockLength
  permit_params :first_name, :last_name, :email, :phone, :admin,
                :reminders_enabled, :change_notifications_enabled, :entra_uid

  index do
    selectable_column
    column :first_name
    column :last_name
    column :email
    column :phone
    column :admin
    actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :admin

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :phone
      row :entra_uid
      row :entra_upn
      row :admin
      row :reminders_enabled
      row :change_notifications_enabled
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone
      f.input :entra_uid
      f.input :admin
      f.input :reminders_enabled
      f.input :change_notifications_enabled
    end
    f.actions
  end
end
