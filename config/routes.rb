Dilkom::Application.routes.draw do
  resources :opmerkings, :except => [:show]
  resources :fouts, :except => [:index, :show]
  resources :overgangs, :except => [:index, :show, :create, :update, :new, :edit]
  resources :rapports, :except => [:index, :create, :update]
  resources :pictures, :except => [:index, :update, :new, :edit]

  resources :proefs, :except => :index do
    collection { post :sorteren }
  end

  resources :niveaus do
    collection { post :sorteren }
  end
  resources :nieuws, :except => [:destroy, :show, :edit, :update]
  get "fronts/paneel"
  get "fronts/handleiding"
  post "fronts/tijd_toevoegen"
  post "fronts/verander_importeer"
  post "fronts/take_picture"
  get "fronts/statistieken"
  get "fronts/singlestat"
  get "fronts/getstat"
  get "fronts/picture_calc"
  get "fronts/index"
  get "fronts/import_form"
  put "fronts/klas_import"
  get "fronts/autoinfo"
  get "fronts/stat_file"
  get "fronts/temp_stat"
  devise_for :lesgevers
 devise_for :lesgevers
 devise_scope :lesgever do
   get '/login' => 'devise/sessions#new'
   get '/logout' => 'devise/sessions#destroy'
 end
  resources :schools

  resources :dags

  resources :lesuurs

  resources :klas, :except => :index
#http://stackoverflow.com/questions/7057990/form-tag-not-working-as-expected
  resources :groeps do
    put 'change', :on => :collection
    get :tst
  end

  resources :zwemmers do
    put 'massdelete', :on => :collection
  end
   resources :lesgevers,:controller => "lesgevers"

  root :to => "groeps#index"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
