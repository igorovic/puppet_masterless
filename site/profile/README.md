## Profile
The idea of a Profile:

* contains code snipits that contain resource types to do real work
* ideally the profile class would lookup any needed data in Hiera via auto-parameter lookup
* one or more profiles would be bundled together to form a role
* individual profile classes could be used across multiple roles if written to support that
