require 'yaml'
require 'io/console'

@yml_filename = ARGV[0]
@accounts_data = YAML.load_file(@yml_filename)
@available_cash = 0

@accounts_data['banknotes'].each do |key, value|
  @available_cash += key * value
end

def withdraw_composing(withdraw_value)
  @accounts_data['banknotes'].each do |key, value|
    while value > 0 do
      if(withdraw_value >= key && value > 0)
        withdraw_value -= key
        @accounts_data['banknotes'][key] -= 1
      else
        break
      end
      value -= 1
    end
  end

  if withdraw_value == 0
    File.open(@yml_filename, 'w') do |h|
      h.write @accounts_data.to_yaml
    end
  end

  return withdraw_value
end


def initialize_account_menu(account_data)

  @account = account_data

  def show_account_menu(account_data = @account)
    puts <<-account_menu

Please Choose From the Following Options:
  1. Display Balance
  2. Withdraw
  3. Log Out

    account_menu

    @option = STDIN.gets.chomp.to_i

    if @option == 1
      puts "\nYour Current Balance is ₴#{account_data[1]['balance']}"
    elsif @option == 2
      attempts = 0

      puts "\nEnter Amount You Wish to Withdraw:"

      while true do
        withdraw = STDIN.gets.chomp

        withdraw_amount = withdraw.to_i

        if withdraw.downcase == 'back'
          break
        elsif withdraw_amount > @available_cash && attempts == 0
          puts "\nERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT:"
          attempts += 1
        elsif withdraw_amount > @available_cash && attempts > 0
          puts "\nERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴#{@available_cash}. IF YOU WANT TO RETURN TYPE 'BACK'. PLEASE ENTER A DIFFERENT AMOUNT:"
        elsif !(/^(?<num>\d+)$/ =~ withdraw) || withdraw_amount < 0
          puts "\nPLEASE PROVIDE CORECT VALUE(ONLY PLURAL NUMBERS)"
        elsif withdraw_composing(withdraw_amount) != 0
          puts "\nERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. IF YOU WANT TO RETURN TYPE 'BACK'. PLEASE ENTER A DIFFERENT AMOUNT:"
        else
          account_data[1]['balance'] -= withdraw_amount
          File.open(@yml_filename, 'w') do |h|
            h.write @accounts_data.to_yaml
          end
          puts "\nYour New Balance is ₴#{account_data[1]['balance']}"
          break
        end
      end
    elsif @option == 3
      puts "\n#{account_data[1]['name']}, Thank You For Using Our ATM. Good-Bye!"
    else
      puts "\nProvide Correct Number From List"
    end
  end

  show_account_menu

  while @option != 3
    show_account_menu
  end

  return true
end

while true do
  puts "\nPlease Enter Your Account Number:"
  @account_number = STDIN.gets.chomp.to_i
  puts "Enter Your Password:"
  @account_password = STDIN.noecho(&:gets).chomp

  check = false

  @accounts_data['accounts'].each do |account|
    if account[0] == @account_number && account[1]['password'] == @account_password
      puts "\nHello #{account[1]['name']}"
      check = initialize_account_menu(account)
    end
  end

  unless check
    puts "\nERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH"
  end
end
