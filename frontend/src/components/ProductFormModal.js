import React, { useState, useEffect } from 'react';
import { Modal, Button, Form, Spinner } from 'react-bootstrap';
import { getSuppliers } from '../services/api';

function ProductFormModal({ show, handleClose, product, onSave }) {
  const [formData, setFormData] = useState({});
  const [suppliers, setSuppliers] = useState([]);
  const [loadingSuppliers, setLoadingSuppliers] = useState(false);

  useEffect(() => {
    if (product) setFormData({ ...product, preferred_supplier: product.preferred_supplier || '' });
    else setFormData({ name: '', sku: '', category: '', unit_price: '', stock_quantity: '', min_stock_level: '', preferred_supplier: '' });

    if (show) {
      const fetchSuppliers = async () => {
        setLoadingSuppliers(true);
        try { const response = await getSuppliers(); setSuppliers(response.data); } 
        catch (error) { console.error("Failed to fetch suppliers", error); } 
        finally { setLoadingSuppliers(false); }
      };
      fetchSuppliers();
    }
  }, [product, show]);

  const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });
  const handleSubmit = (e) => { e.preventDefault(); onSave(formData); };

  return (
    <Modal show={show} onHide={handleClose}>
      <Modal.Header closeButton><Modal.Title>{product ? 'Edit Product' : 'Create Product'}</Modal.Title></Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <Form.Group className="mb-3"><Form.Label>Name</Form.Label><Form.Control type="text" name="name" value={formData.name || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>SKU</Form.Label><Form.Control type="text" name="sku" value={formData.sku || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Category</Form.Label><Form.Control type="text" name="category" value={formData.category || ''} onChange={handleChange} /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Unit Price</Form.Label><Form.Control type="number" name="unit_price" value={formData.unit_price || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Stock Quantity</Form.Label><Form.Control type="number" name="stock_quantity" value={formData.stock_quantity || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Minimum Stock Level</Form.Label><Form.Control type="number" name="min_stock_level" value={formData.min_stock_level || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>Preferred Supplier</Form.Label>
            {loadingSuppliers ? <Spinner size="sm" /> : (
              <Form.Select name="preferred_supplier" value={formData.preferred_supplier || ''} onChange={handleChange}>
                <option value="">None</option>
                {suppliers.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
              </Form.Select>
            )}
          </Form.Group>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>Close</Button>
          <Button variant="primary" type="submit">Save Changes</Button>
        </Modal.Footer>
      </Form>
    </Modal>
  );
}

export default ProductFormModal;
