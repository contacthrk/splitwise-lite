module ApplicationHelper
  def display_date(date)
    date&.strftime('%b %d')
  end

  def display_money(amt)
    amt && number_to_currency(amt)
  end

  def sidebar_highlight_class(user_id)
    current_page?(person_path(user_id)) && 'active'
  end

  def journal_narration_link(txt, source)
    src_path = case source
               when Settlement
                 settlement_path(source)
               when Expense
                 expense_path(source)
               end
    link_to txt, src_path, remote: true
  end

  def journal_source_deletion_link(txt, source)
    src_path = case source
               when Settlement
                 settlement_path(source)
               when Expense
                 expense_path(source)
               end
    link_to txt, src_path, method: :delete, class: 'remove-btn', data: { confirm: 'Are you sure ?' }
  end
end
