extends RigidBody

export var explosion_decal : Resource
export var explosion_praticles : Resource
export var explosion_force : int = 30

var items_in_radius : Array


func _ready():
	randomize()

# Adding the rigidbodies to an array that entered into the explosion area.
func _on_Area_body_entered(body):
	if body.name != self.name:
		if body is RigidBody:
			items_in_radius.append(body)

# Deleting the rigidbodies from the array that exited the explosion area.
func _on_Area_body_exited(body):
	if body is RigidBody:
		items_in_radius.erase(body)

func explosion():
	var force_dir : Vector3
	var random_vector : Vector3
	
	#Breaking all the breakables.
	for i in items_in_radius:
		if i.is_in_group("breakable"):
			#Calling the break_object function from the breakable script.
			i.break_object()
			
	#Here the code waits before all the breakables break.
	#You can set the yield timer to 0.05 or higher if you will have issues with the explosion force. 
	yield(get_tree().create_timer(0.04), "timeout")
	
	#Applying the explosion force for every Rigidbody in the array.
	for j in items_in_radius:
		#Getting a direction vector between the bomb and all nearby RigidBodies. This line of code later helps to calculate a trajectory for the Rigidbodies.
		force_dir = self.translation.direction_to(j.translation)
		#Generating a position on the object where the force will be applied. This line of code makes the Rigidbodies randomly rotate after the explosion.
		random_vector = Vector3(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1)) * force_dir
		j.apply_impulse(random_vector, force_dir * explosion_force)

# Time to explode! 
func _on_Timer_timeout():
	explosion()
	
	#Explosion effects 
	var decal = explosion_decal.instance()
	self.get_parent().add_child(decal)
	decal.translation = self.translation
	decal.translation.y = 0.2
	
	#Explosion particles made by drcd1. Here is the link: https://github.com/drcd1/GodotSimpleExplosionVFX
	var particles = explosion_praticles.instance()
	self.get_parent().add_child(particles)
	particles.translation = self.translation
	particles.emitting = true
