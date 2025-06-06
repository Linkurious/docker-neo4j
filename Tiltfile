
# version_settings() enforces a minimum Tilt version
# https://docs.tilt.dev/api.html#api.version_settings
version_settings(constraint='>=0.30.8')

load('ext://kubectl_build', 'kubectl_build')
load('ext://helm_resource', 'helm_resource', 'helm_repo')

ctx = k8s_context()
if ctx.endswith('k8s-preprod'):
  allow_k8s_contexts(ctx)

if not k8s_namespace().endswith("dev"):
  fail("You are not targeting a dev namespace")
builder = "builder-" + k8s_namespace()

neo4j_workload_name = 'neo4jv5'
neo4j_release_name = ctx.removesuffix('@k8s-preprod') + '-tilt-neo4jv5'
helm_resource(
  name=neo4j_workload_name,
  release_name=neo4j_release_name,
  chart='charts/neo4jv5-internal',
  deps=['charts/neo4jv5-internal'],
  namespace='neo4j-dev',
  flags=['--render-subchart-notes']
  # image_deps=['linkurious-server'],
  # image_keys=[('linkurious-enterprise.image.repository','linkurious-enterprise.image.tag')]
  )
k8s_resource(workload=neo4j_workload_name,
  links=[
      neo4j_release_name + '.neo4j-dev.k8s.preprod.linkurious.net',
  ]
)
