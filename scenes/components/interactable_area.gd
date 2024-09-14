class_name InteractableArea extends Area2D

signal interacted

func interact(player: PlayerActor):
	interacted.emit(player)
