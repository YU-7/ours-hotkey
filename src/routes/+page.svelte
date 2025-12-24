<script lang="ts">
  import {
    ArrowLeftRightIcon,
    BikeIcon,
    BookIcon,
    HouseIcon,
    TreePalmIcon,
  } from "@lucide/svelte";
  import { Navigation } from "@skeletonlabs/skeleton-svelte";

  const links = [
    { label: "系统级热键", href: "/#", icon: HouseIcon },
    { label: "快捷命令", href: "/#", icon: BookIcon },
    { label: "Vim模式", href: "/#", icon: BikeIcon },
    { label: "软件设置", href: "/#", icon: TreePalmIcon },
  ];

  const buttonClasses = "btn hover:preset-tonal";
  let anchorRail = `${buttonClasses} aspect-square w-full max-w-[84px] flex flex-col items-center gap-0.5`;
  let anchorSidebar = `${buttonClasses} justify-start px-2 w-full`;

  let layoutRail = $state(true);

  function toggleLayout() {
    layoutRail = !layoutRail;
  }
</script>

<div
  class="w-full h-screen grid grid-cols-[auto_1fr] items-stretch border border-surface-200-800 overflow-hidden"
>
  <!-- --- -->
  <Navigation
    layout={layoutRail ? "rail" : "sidebar"}
    class={layoutRail
      ? "h-full overflow-hidden min-h-0 max-h-full"
      : "grid grid-rows-[1fr_auto] gap-4 h-full overflow-hidden min-h-0 max-h-full"}
    style="max-height: 100%; overflow: hidden;"
  >
    <Navigation.Content class="h-full overflow-hidden flex flex-col min-h-0">
      <Navigation.Header>
        <Navigation.Trigger onclick={toggleLayout}>
          <ArrowLeftRightIcon class={layoutRail ? "size-5" : "size-4"} />
          {#if !layoutRail}<span>Resize</span>{/if}
        </Navigation.Trigger>
      </Navigation.Header>
      <Navigation.Menu class="flex-1 overflow-y-auto min-h-0">
        {#each links as link (link)}
          {@const Icon = link.icon}
          <Navigation.TriggerAnchor>
            <Icon class={layoutRail ? "size-5" : "size-4"} />
            <Navigation.TriggerText>{link.label}</Navigation.TriggerText>
          </Navigation.TriggerAnchor>
        {/each}
      </Navigation.Menu>
    </Navigation.Content>
  </Navigation>
  <!-- --- -->
  <div class="flex justify-center items-center overflow-hidden min-h-0">
    <pre class="pre">Layout: {layoutRail ? "Rail" : "Sidebar"}</pre>
  </div>
</div>
