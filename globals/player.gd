extends Node

const MAX_MONEY = 999
const STARTING_MONEY = 50

signal money_changed

var money: int:
	set(new_money):
		money = min(max(new_money, 0), MAX_MONEY)
		money_changed.emit()

func spend_money(amount: int) -> bool:
	if money < amount: return false
	money -= amount
	return true

func gain_money(amount: int):
	money += amount

func reset():
	money = STARTING_MONEY
