<script lang="ts">
  import {
    ArrowLeftRightIcon,
    BikeIcon,
    BookIcon,
    HouseIcon,
    TreePalmIcon,
  } from "@lucide/svelte";
  import { Navigation } from "@skeletonlabs/skeleton-svelte";
  import Settings from "$lib/components/Settings.svelte";

  type ViewType = "hotkeys" | "commands" | "vim" | "settings";

  const links = [
    { label: "系统级热键", id: "hotkeys" as ViewType, icon: HouseIcon },
    { label: "快捷命令", id: "commands" as ViewType, icon: BookIcon },
    { label: "Vim模式", id: "vim" as ViewType, icon: BikeIcon },
    { label: "软件设置", id: "settings" as ViewType, icon: TreePalmIcon },
  ];

  const buttonClasses = "btn hover:preset-tonal";
  let anchorRail = `${buttonClasses} aspect-square w-full max-w-[84px] flex flex-col items-center gap-0.5`;
  let anchorSidebar = `${buttonClasses} justify-start px-2 w-full`;

  let layoutRail = $state(true);
  let currentView = $state<ViewType>("hotkeys");

  function toggleLayout() {
    layoutRail = !layoutRail;
  }

  function handleNavClick(viewId: ViewType) {
    currentView = viewId;
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
          <Navigation.TriggerAnchor
            onclick={() => handleNavClick(link.id)}
            class={currentView === link.id ? "bg-surface-300-700" : ""}
          >
            <Icon class={layoutRail ? "size-5" : "size-4"} />
            <Navigation.TriggerText>{link.label}</Navigation.TriggerText>
          </Navigation.TriggerAnchor>
        {/each}
      </Navigation.Menu>
    </Navigation.Content>
  </Navigation>
  <!-- --- -->
  <div class="overflow-hidden min-h-0 overflow-y-auto">
    {#if currentView === "settings"}
      <Settings />
    {:else if currentView === "hotkeys"}
      <div class="flex justify-center items-center h-full p-6">
        <div class="text-center">
          <h2 class="text-xl font-semibold mb-2">系统级热键</h2>
          <p class="text-surface-600-300">功能开发中...</p>
        </div>
      </div>
    {:else if currentView === "commands"}
      <div class="flex justify-center items-center h-full p-6">
        <div class="text-center">
          <h2 class="text-xl font-semibold mb-2">快捷命令</h2>
          <p class="text-surface-600-300">功能开发中...</p>
        </div>
      </div>
    {:else if currentView === "vim"}
      <div class="flex justify-center items-center h-full p-6">
        <div class="text-center">
          <h2 class="text-xl font-semibold mb-2">Vim模式</h2>
          <p class="text-surface-600-300">功能开发中...</p>
        </div>
      </div>
    {/if}
  </div>
</div>
