class LoanReturnsController < ApplicationController
  def create
    loan = Current.user.loans.find(params[:loan_id])
    loan.return!
    redirect_to loan, notice: "Back where it belongs. Return recorded.", status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    redirect_to loan, alert: error.record.errors.full_messages.to_sentence, status: :see_other
  end
end
