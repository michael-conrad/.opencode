(define (domain grounder_deliver-1-domain)
 (:requirements :strips :typing)
 (:types package location)
 (:constants
   depot hub - location
   pkg1 - package
 )
 (:predicates 
             (at ?p - package ?l - location)
             (vehicle-at ?l - location)
 )
 (:action move_depot_depot
  :parameters ()
  :precondition (and (vehicle-at depot))
  :effect (and (not (vehicle-at depot)) (vehicle-at depot)))
 (:action move_depot_hub
  :parameters ()
  :precondition (and (vehicle-at depot))
  :effect (and (not (vehicle-at depot)) (vehicle-at hub)))
 (:action move_hub_depot
  :parameters ()
  :precondition (and (vehicle-at hub))
  :effect (and (not (vehicle-at hub)) (vehicle-at depot)))
 (:action move_hub_hub
  :parameters ()
  :precondition (and (vehicle-at hub))
  :effect (and (not (vehicle-at hub)) (vehicle-at hub)))
 (:action load_pkg1_depot
  :parameters ()
  :precondition (and (at pkg1 depot) (vehicle-at depot))
  :effect (and (not (at pkg1 depot))))
 (:action load_pkg1_hub
  :parameters ()
  :precondition (and (at pkg1 hub) (vehicle-at hub))
  :effect (and (not (at pkg1 hub))))
 (:action unload_pkg1_depot
  :parameters ()
  :precondition (and (vehicle-at depot))
  :effect (and (at pkg1 depot)))
 (:action unload_pkg1_hub
  :parameters ()
  :precondition (and (vehicle-at hub))
  :effect (and (at pkg1 hub)))
)
