use crate::compositor::RenderBackend;
use crate::config::Config;
use ash::vk;
use ash::version::InstanceV1_0;

pub struct VulkanBackend {
    instance: ash::Instance,
    physical_device: vk::PhysicalDevice,
    device: ash::Device,
    queue: vk::Queue,
    config: Config,
}

impl VulkanBackend {
    pub fn new(config: &Config) -> Self {
        let entry = ash::Entry::new().expect("Failed to load Vulkan");
        let app_name = std::ffi::CString::new("GameFrame").unwrap();
        let engine_name = std::ffi::CString::new("GameFrame Engine").unwrap();
        let app_info = vk::ApplicationInfo {
            s_type: vk::StructureType::APPLICATION_INFO,
            p_application_name: app_name.as_ptr(),
            application_version: vk::make_version(1, 0, 0),
            p_engine_name: engine_name.as_ptr(),
            engine_version: vk::make_version(1, 0, 0),
            api_version: match config.gpu.vulkan_version.as_str() {
                "1.3" => vk::make_version(1, 3, 0),
                _ => vk::make_version(1, 2, 0),
            },
            ..Default::default()
        };

        let instance_create_info = vk::InstanceCreateInfo {
            s_type: vk::StructureType::INSTANCE_CREATE_INFO,
            p_application_info: &app_info,
            ..Default::default()
        };

        let instance = unsafe {
            entry.create_instance(&instance_create_info, None).expect("Failed to create Vulkan instance")
        };

        let physical_devices = unsafe {
            instance.enumerate_physical_devices().expect("Failed to enumerate physical devices")
        };
        let physical_device = physical_devices
            .into_iter()
            .find(|&device| {
                let properties = unsafe { instance.get_physical_device_properties(device) };
                let vendor_id = properties.vendor_id;
                match config.gpu.vendor.as_str() {
                    "nvidia" => vendor_id == 0x10DE,
                    "amd" => vendor_id == 0x1002,
                    "intel" => vendor_id == 0x8086,
                    "auto" => true,
                    _ => false,
                }
            })
            .expect("No suitable physical device found");

        let queue_create_info = vk::DeviceQueueCreateInfo {
            s_type: vk::StructureType::DEVICE_QUEUE_CREATE_INFO,
            queue_family_index: 0,
            queue_count: 1,
            p_queue_priorities: [1.0].as_ptr(),
            ..Default::default()
        };
        let device_create_info = vk::DeviceCreateInfo {
            s_type: vk::StructureType::DEVICE_CREATE_INFO,
            queue_create_info_count: 1,
            p_queue_create_infos: &queue_create_info,
            ..Default::default()
        };
        let device = unsafe {
            instance.create_device(physical_device, &device_create_info, None).expect("Failed to create Vulkan device")
        };
        let queue = unsafe { device.get_device_queue(0, 0) };

        VulkanBackend { instance, physical_device, device, queue, config: config.clone() }
    }
}

impl RenderBackend for VulkanBackend {
    fn render(&mut self) {
        println!(
            "Rendering with Vulkan (Vendor: {}, Resolution: {}, Refresh: {} Hz, Scaling: {}, HDR: {}, Filter: {})",
            self.config.gpu.vendor, self.config.resolution, self.config.refresh_rate,
            self.config.scaling_mode, self.config.hdr, self.config.rendering.filter
        );
    }
}

impl Drop for VulkanBackend {
    fn drop(&mut self) {
        unsafe {
            self.device.destroy_device(None);
            self.instance.destroy_instance(None);
        }
    }
}
