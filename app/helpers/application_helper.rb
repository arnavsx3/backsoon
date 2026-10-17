module ApplicationHelper
  def initials(name)
    name.to_s.split.first(2).map { |part| part.first }.join.upcase
  end

  def friendly_date(date)
    date&.strftime("%b %-d, %Y") || "—"
  end

  def loan_status(loan)
    return "Returned" if loan.returned?
    return "Overdue" if loan.overdue?
    loan.due_on == Date.current ? "Due today" : "On loan"
  end

  def loan_status_class(loan)
    return "bg-emerald-50 text-emerald-800" if loan.returned?
    loan.overdue? ? "bg-orange-50 text-orange-800" : "bg-teal-50 text-teal-800"
  end

  def nav_link(label, path, controllers)
    active = controller_name.in?(controllers)
    link_to label, path, class: "nav-link #{'nav-link-active' if active}", aria: { current: active ? "page" : nil }
  end
end
