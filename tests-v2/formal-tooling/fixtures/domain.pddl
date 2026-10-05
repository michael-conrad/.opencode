(define (domain deliver)
  (:requirements :strips :typing)
  (:types package location)
  (:predicates (at ?p - package ?l - location)
               (vehicle-at ?l - location))
  (:action move
    :parameters (?from ?to - location)
    :precondition (vehicle-at ?from)
    :effect (and (not (vehicle-at ?from)) (vehicle-at ?to)))
  (:action load
    :parameters (?p - package ?l - location)
    :precondition (and (at ?p ?l) (vehicle-at ?l))
    :effect (not (at ?p ?l)))
  (:action unload
    :parameters (?p - package ?l - location)
    :precondition (vehicle-at ?l)
    :effect (at ?p ?l))
)
