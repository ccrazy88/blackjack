# blackjack.rb
# Chrisna Aing, 6/21/10
# A simple game of blackjack.  Employs a basic command-line interface and
# (hopefully) runs on a vanilla installation of Ruby 1.8.6.
# The game ends when all players run out of money.

require "card"
require "deck"
require "hand"
require "player"

# Given a question and a range (min, max), returns user-inputted answer to said
# question; bugs the user until they enter a valid answer.
def receive_int(question, min, max)
  answer = receive_answer(question)
  while answer != answer.to_i.to_s or
    (answer == answer.to_i.to_s and (answer.to_i < min or answer.to_i > max))
    puts "Please enter a number between #{min} and #{max}."
    answer = receive_answer(question)
  end
  return answer.to_i
end


class Game
  attr_accessor :players

  def initialize(players, decks)
    @players = Array.new
    @dealer = Dealer.new
    @deck = Deck.new(decks)

    players.times do |i|
      @players.push(Human.new("Player #{i + 1}"))
    end
  end

  def to_s
    @players.each do |player|
      puts player.to_s
    end
  end

  # Initialization of everything.
  def start_round
    @deck.start_deal
    @dealer.start_round
    @dealer.new_hand
    @players.each do |player|
      player.start_round
      player.new_hand
    end
  end

  def remove_bankrupt_players
    @players = @players.select {|player| player.money > 0}
    puts "The game is over." if @players.empty?
  end

  def take_bets
    @players.each do |player|
      raise ArgumentError.new("Player shouldn't be bankrupt.") unless
        player.money > 0

      prompt = "#{player.name}, how much to bet ($1-$#{player.money})? "
      player.set_bet(player.first_hand, receive_int(prompt, 1, player.money))
    end
  end

  def deal_card(hand)
    # Helper function.
    hand.add(@deck.next)
  end

  def deal_first_cards
    # Dealer is dealt cards last.
    all_players = @players + [@dealer]
    2.times do
      all_players.each do |player|
        deal_card(player.first_hand)
      end
    end
  end

  def resolve_blackjacks
    if @dealer.first_hand.blackjack?
      puts "Dealer gets blackjack!"
      resolve_bets
    else
      @players.each do |player|
        if player.first_hand.blackjack?
          # Approximately a 3:2 payout to preserve integerness.
          payout = 3 * player.first_hand.bet / 2
          puts "#{player.name} wins $#{payout} with a blackjack!"
          player.money += payout
        end
      end
    end
  end

  def fill_hands
  end

  def resolve_bets
    puts "Time to resolve all hands!"
    dealer_cards = @dealer.first_hand.cards.join(" ")
    dealer_score = @dealer.first_hand.to_i
    puts "The dealer's hand is #{dealer_cards} -> #{dealer_score}."
    # For each hand:
    @players.each do |player|
      player.hands.each do |hand|
        # Blackjack hands are already resolved.
        if !hand.blackjack?
          cards = hand.cards.join(" ")
          score = hand.to_i
          bet = hand.bet
          # Now, we reward winners,
          if !hand.bust? and hand.to_i > dealer_score
            puts "#{player.name} wins $#{bet} with #{cards} -> #{score}!"
            player.money += 2 * hand.bet
          # square things with pushers,
          elsif !hand.bust? and hand.to_i == dealer_score
            puts "#{player.name} ties with #{cards} -> #{score}."
            player.money += hand.bet
          # and leave losers alone.
          else
            puts "#{player.name} loses $#{bet} with #{cards} -> #{score}."
          end
        end
      end
    end
  end

  def play
    while true
      puts "New round starting!"
      start_round
      remove_bankrupt_players
      break if @players.empty?
      take_bets
      deal_first_cards
      resolve_blackjacks
      # If the dealer received a blackjack, the round is over.
      if !@dealer.first_hand.blackjack?
        fill_hands
        resolve_bets
      end
      # Prettiness.
      puts
    end
  end
end


puts "Welcome to blackjack!"
players = receive_int("How many players (1-7)? ", 1, 7)
decks = receive_int("How many decks will the shoe hold (1-8)? ", 1, 8)

blackjack_game = Game.new(players, decks)
blackjack_game.play
