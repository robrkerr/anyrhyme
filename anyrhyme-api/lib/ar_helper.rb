class ArHelper
	def find_ids_with_single_column ar_table, column, all_entries
		return {} if all_entries.length == 0
    existing_entries_to_id = {}
    ar_table.
      select("#{column}, id").
      where(column => all_entries).
      find_each do |row|
        existing_entries_to_id[row.send(column)] = row.id
      end
    existing_entries_to_id
  end

	def find_ids_with_multiple_columns ar_table, columns, all_entries
		return {} if all_entries.length == 0
    existing_entries_to_id = {}
    set_string = all_entries.map { |entry| "(" + entry.map { |e| ActiveRecord::Base.connection.quote(e) }.join(",") + ")" }.join(",")
    columns_string = columns.map(&:to_s).join(",")
    ar_table.
      select("#{columns_string}, id").
      where("#{columns_string}) IN (#{set_string}").
      find_each do |row|
      	key = columns.map { |column| row.send(column) }
        existing_entries_to_id[key] = row.id
      end
    existing_entries_to_id
  end  
end