/**
 * Modal for creating a new expense category
 */

import { TextField, Button, Modal } from "../vibes";
import { createCategory } from "../services/api";
import { useCategoryForm } from "../hooks/useCategoryForm";
import { Category } from "../types";

interface AddCategoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onCreated: (category: Category) => void;
}

export function AddCategoryModal({
  isOpen,
  onClose,
  onCreated,
}: AddCategoryModalProps) {
  const { name, error, isSubmitting, handleChange, handleSubmit } =
    useCategoryForm({
      onSubmit: async (name) => {
        const category = await createCategory(name);
        onCreated(category);
      },
    });

  const handleClose = () => {
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add New Category">
      <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
        <TextField
          label="Category Name"
          type="text"
          placeholder="e.g. Subscriptions"
          value={name}
          onChange={(e) => handleChange(e.target.value)}
          error={error}
          fullWidth
          required
        />
        <div style={{ display: "flex", gap: "0.5rem" }}>
          <Button
            type="submit"
            variant="primary"
            disabled={isSubmitting}
            fullWidth
          >
            {isSubmitting ? "Adding..." : "Add Category"}
          </Button>
          <Button
            type="button"
            variant="secondary"
            onClick={handleClose}
          >
            Cancel
          </Button>
        </div>
      </form>
    </Modal>
  );
}
