 # Roles and Profiles
 A lot of writings already exist about roles and profiles.
 * https://www.craigdunn.org/2012/05/239/
 * https://github.com/bentlema/puppet-tutorial-pe/blob/master/tutorial/vbox/11-Roles-and-Profiles.md
 
 They are basically puppet code patterns.
 
 ## Role
 The idea of a Role:
* Each node is assigned exactly one role
* That single role class would be assigned to the node using any node classification method

The role class
* simply contains a list of include profile:: statements
* traditionally does NOT contain any conditional logic


