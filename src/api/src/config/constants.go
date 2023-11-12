package config

const (
	LifecycleDev  = "dev"
	LifecycleProd = "prod"
)

func LifecycleIsProd() bool {
	return GetLifecycle() == LifecycleProd
}
