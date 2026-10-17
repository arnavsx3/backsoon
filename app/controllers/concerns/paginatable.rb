module Paginatable
  extend ActiveSupport::Concern

  private
    def paginate(scope)
      total = scope.count
      pages = [ (total / 20.0).ceil, 1 ].max
      page = params[:page].to_s.to_i.clamp(1, pages)
      @pagination = { page: page, pages: pages, total: total }
      scope.limit(20).offset((page - 1) * 20)
    end
end
