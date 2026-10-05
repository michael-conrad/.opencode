(define (problem deliver-1)
  (:domain deliver)
  (:objects pkg1 - package
            depot hub - location)
  (:init (at pkg1 depot) (vehicle-at depot))
  (:goal (at pkg1 hub))
)
