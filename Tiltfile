
# version_settings() enforces a minimum Tilt version
# https://docs.tilt.dev/api.html#api.version_settings
version_settings(constraint='>=0.30.8')

load('ext://kubectl_build', 'kubectl_build')
load('ext://helm_resource', 'helm_resource', 'helm_repo')
# default_registry('prepush.docker.nexus3.vpc.prod.scw-par1.linkurious.net')

ctx = k8s_context()
if ctx.endswith('k8s-dev'):
  allow_k8s_contexts(ctx)

if not k8s_namespace().endswith("dev"):
  fail("You are not targeting a dev namespace")
builder = "builder-" + k8s_namespace()

neo4j_workload_name = ctx.removesuffix('@k8s-dev') + '-tilt-neo4jv5'
helm_resource(
  name=neo4j_workload_name,
  chart='charts/neo4jv5-internal',
  deps=['charts/neo4jv5-internal'],
  namespace='neo4j-dev',
  flags=['--render-subchart-notes']
  # image_deps=['linkurious-server'],
  # image_keys=[('linkurious-enterprise.image.repository','linkurious-enterprise.image.tag')]
  )
k8s_resource(workload=neo4j_workload_name,
  links=[
      neo4j_workload_name + '.neo4j-dev.k8s.dev.linkurious.net',
  ]
)